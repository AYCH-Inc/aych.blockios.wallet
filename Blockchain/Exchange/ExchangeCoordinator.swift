//
//  ExchangeCoordinator.swift
//  Blockchain
//
//  Created by AlexM on 7/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices
import ToolKit
import NetworkKit
import PlatformKit
import PlatformUIKit

class ExchangeCoordinator {
    
    // MARK: Public Properties
    
    static let shared = ExchangeCoordinator()
    
    // MARK: Private Properties
    
    private var navController: BaseNavigationController!
    private weak var rootViewController: UIViewController?
    private let disposables: CompositeDisposable = CompositeDisposable()
    private let bag: DisposeBag = DisposeBag()
    private let repository: ExchangeAccountRepositoryAPI
    private let authenticator: ExchangeAccountAuthenticatorAPI
    private let loadingIndicatorAPI: LoadingViewPresenting
    private let appSettings: BlockchainSettings.App
    
    // MARK: Init
    
    init(repository: ExchangeAccountRepositoryAPI = ExchangeAccountRepository(),
         authenticator: ExchangeAccountAuthenticatorAPI = ExchangeAccountAuthenticator(),
         loadingIndicatorAPI: LoadingViewPresenting = LoadingViewPresenter.shared,
         appSettings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.repository = repository
        self.authenticator = authenticator
        self.loadingIndicatorAPI = loadingIndicatorAPI
        self.appSettings = appSettings
    }
    
    // MARK: Public Functions
    
    func start() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        start(from: rootViewController)
    }
    
    func start(from viewController: UIViewController) {
        rootViewController = viewController
        hasLinkedExchangeAccount().subscribe(onSuccess: { [weak self] linked in
            guard let self = self else { return }
            switch linked {
            case true:
                self.syncAddressesAndLaunchExchange()
            case false:
                self.showExchangeConnectScreen()
            }
        }, onError: { error in
            Logger.shared.error(error)
        }).disposed(by: bag)
        
        appSettings.didTapOnExchangeDeepLink = false
    }
    
    // Called when the KYC process is completed or stopped before completing.
    func stop() {
        if navController == nil { return }
        navController.dismiss(animated: true)
        navController = nil
    }
    
    private func showExchangeConnectScreen() {
        guard let root = rootViewController else { return }
        let connect = ExchangeConnectViewController.makeFromStoryboard()
        
        connect.connectRelay
            .flatMap(weak: self) { (self, _) -> Observable<Bool> in
                self.userRequiresEmailVerification()
            }
            .subscribe(onNext: { [weak self] showEmailVerification in
                if showEmailVerification {
                    self?.showEmailConfirmationScreen()
                } else {
                    self?.syncAddressesAndLaunchExchange()
                }
            })
            .disposed(by: bag)
        
        connect.learnMoreRelay
            .map { _ -> URLComponents in
                var components = URLComponents()
                components.path = BlockchainAPI.shared.exchangeURL
                return components
            }
            .compactMap { $0.string?.removingPercentEncoding }
            .compactMap { URL(string: $0) }
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                let controller = SFSafariViewController(url: url)
                controller.modalPresentationStyle = .overCurrentContext
                self.navController.present(controller, animated: true, completion: nil)
            })
            .disposed(by: bag)
        navController = presentInNavigationController(connect, in: root)
    }
    
    private func userRequiresEmailVerification() -> Observable<Bool> {
        return BlockchainDataRepository.shared.fetchNabuUser().asObservable().take(1).flatMap {
            return Observable.just($0.email.verified == false)
        }
    }
    
    private func showEmailConfirmationScreen() {
        guard let navController = navController else { return }
        let emailConfirmationScreen = ExchangeEmailVerificationViewController.makeFromStoryboard()
        
        let disposable = emailConfirmationScreen.verificationObserver
            .dismissNavControllerOnDisposal(navController: self.navController)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                emailConfirmationScreen.dismiss(animated: true, completion: nil)
                self.showEmailVerifiedAlert()
            }, onError: { (error) in
                Logger.shared.error(error)
            })
        
        disposables.insertWithDiscardableResult(disposable)
        let navigationController = BaseNavigationController(rootViewController: emailConfirmationScreen)
        navigationController.modalPresentationStyle = .fullScreen
        navController.present(navigationController, animated: true, completion: nil)
    }
    
    @discardableResult private func presentInNavigationController(
        _ viewController: UIViewController,
        in presentingViewController: UIViewController
        ) -> BaseNavigationController {
        let navController = BaseNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        presentingViewController.present(navController, animated: true)
        return navController
    }
    
    // MARK: Alerts
    
    private func showEmailVerifiedAlert() {
        let block = { [weak self] in
            guard let self = self else { return }
            self.syncAddressesAndLaunchExchange()
        }
        let action = AlertAction(
            style: .default(LocalizationConstants.Exchange.ConnectionPage.Actions.connectNow),
            metadata: .block(block))
        let alert = AlertModel(
            headline: LocalizationConstants.Exchange.EmailVerification.verified,
            body: LocalizationConstants.Exchange.EmailVerification.verifiedDescription,
            actions: [action],
            image: UIImage(named: "email_good"),
            style: .sheet
        )
        let alertView = AlertView.make(with: alert) { action in
            if let metadata = action.metadata {
                guard case let .block(value) = metadata else { return }
                value()
            }
        }
        alertView.show()
    }
    
    private func syncAddressesAndLaunchExchange() {
        if isLinkingToExistingExchangeUser() {
            syncAddressesAndLinkExchangeToWallet()
        } else {
            syncAddressAndLinkWalletToExchange()
        }
    }
    
    private func syncAddressAndLinkWalletToExchange() {
        /// Users that have linked their Exchange account should be sent to the `/trade`
        /// page and not the Exchange landing page.
        guard let exchangeURL = URL(string: BlockchainAPI.shared.exchangeURL + "/trade") else { return }
        repository.syncDepositAddresses()
            .andThen(hasLinkedExchangeAccount())
            .flatMap(weak: self, { (self, hasLinkedExchangeAccount) -> Single<URL> in
                return hasLinkedExchangeAccount ? Single.just(exchangeURL) : self.authenticator.exchangeURL
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .showSheetOnSubscription(bottomAlertSheet: syncingBottomAlertSheet)
            .hideBottomSheetOnSuccessOrError(bottomAlertSheet: syncingBottomAlertSheet)
            .showSheetAfterFailure(bottomAlertSheet: failureLinkingBottomSheet)
            .subscribe(onSuccess: { url in
                UIApplication.shared.open(url)
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    private func syncAddressesAndLinkExchangeToWallet() {
        authenticator.exchangeLinkID
            .flatMapCompletable(weak: self) { (self, linkID) -> Completable in
                return self.authenticator.linkToExistingExchangeUser(linkID: linkID)
            }
            .andThen(repository.syncDepositAddresses())
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .showSheetOnSubscription(bottomAlertSheet: syncingBottomAlertSheet)
            .hideBottomSheetOnCompletionOrError(bottomAlertSheet: syncingBottomAlertSheet)
            .showSheetAfterCompletion(bottomAlertSheet: successfulLinkingBottomSheet)
            .showSheetAfterFailure(bottomAlertSheet: failureLinkingBottomSheet)
            .dismissNavControllerOnSubscription(navController: navController)
            .subscribe(onCompleted: {
                // Do nothing, the user's account should now be linked.
                self.appSettings.exchangeLinkIdentifier = nil
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    private func hasLinkedExchangeAccount() -> Single<Bool> {
        return repository.hasLinkedExchangeAccount
    }
    
    private func isLinkingToExistingExchangeUser() -> Bool {
        return appSettings.exchangeLinkIdentifier != nil
    }
    
    // MARK: Lazy Private Properties
    
    private lazy var syncingBottomAlertSheet: BottomAlertSheet = {
        let loading = LoadingBottomAlert(
            title: LocalizationConstants.Exchange.Alerts.connectingYou,
            subtitle: LocalizationConstants.Exchange.Alerts.newWindow,
            gradient: .exchange
        )
        return BottomAlertSheet.make(with: loading)
    }()
    
    private lazy var successfulLinkingBottomSheet: BottomAlertSheet = {
        let success = ThumbnailBottomAlert(
            title: LocalizationConstants.Exchange.Alerts.success,
            subtitle: LocalizationConstants.Exchange.Alerts.successDescription,
            gradient: .exchange,
            thumbnail: #imageLiteral(resourceName: "green-checkmark-bottom-sheet")
        )
        return BottomAlertSheet.make(with: success)
    }()
    
    private lazy var failureLinkingBottomSheet: BottomAlertSheet = {
        let success = ThumbnailBottomAlert(
            title: LocalizationConstants.Exchange.Alerts.error,
            subtitle: LocalizationConstants.Exchange.Alerts.errorDescription,
            gradient: .exchange,
            thumbnail: #imageLiteral(resourceName: "icon-error-bottom-sheet")
        )
        return BottomAlertSheet.make(with: success)
    }()
}

fileprivate extension ObservableType {
    
    func dismissNavControllerOnDisposal(navController: BaseNavigationController) -> Observable<Element> {
        return self.do(onDispose: {
            navController.popToRootViewController(animated: true)
            navController.dismiss(animated: true, completion: nil)
            AppCoordinator.shared.closeSideMenu()
        })
    }
    
}

private extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Never {
    
    func dismissNavControllerOnDisposal(navController: BaseNavigationController?) -> Completable {
        return self.do(onDispose: {
            navController?.popToRootViewController(animated: true)
            navController?.dismiss(animated: true, completion: nil)
            AppCoordinator.shared.closeSideMenu()
        })
    }
    
    func dismissNavControllerOnSubscription(navController: BaseNavigationController?) -> Completable {
        return self.do(onSubscribed: {
            navController?.popToRootViewController(animated: true)
            navController?.dismiss(animated: true, completion: nil)
            AppCoordinator.shared.closeSideMenu()
        })
    }
    
}

