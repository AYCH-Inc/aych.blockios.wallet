//
//  PitCoordinator.swift
//  Blockchain
//
//  Created by AlexM on 7/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift
import SafariServices

class PitCoordinator {
    
    // MARK: Public Properties
    
    static let shared = PitCoordinator()
    
    // MARK: Private Properties
    
    private var navController: BaseNavigationController!
    private weak var rootViewController: UIViewController?
    private let disposables: CompositeDisposable = CompositeDisposable()
    private let bag: DisposeBag = DisposeBag()
    private let repository: PITAccountRepositoryAPI
    private let authenticator: PitAccountAuthenticatorAPI
    private let loadingIndicatorAPI: LoadingViewPresenting
    private let appSettings: BlockchainSettings.App
    
    // MARK: Init
    
    init(repository: PITAccountRepositoryAPI = PITAccountRepository(),
         authenticator: PitAccountAuthenticatorAPI = PitAccountAuthenticator(),
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
        hasLinkedPITAccount().subscribe(onSuccess: { [weak self] linked in
            guard let self = self else { return }
            switch linked {
            case true:
                self.syncAddressesAndLaunchPIT()
            case false:
                self.showPitConnectScreen()
            }
        }, onError: { error in
            Logger.shared.error(error)
        }).disposed(by: bag)
        
        appSettings.didTapOnPitDeepLink = false
    }
    
    // Called when the KYC process is completed or stopped before completing.
    func stop() {
        if navController == nil { return }
        navController.dismiss(animated: true)
        navController = nil
    }
    
    private func showPitConnectScreen() {
        guard let root = rootViewController else { return }
        let connect = PitConnectViewController.makeFromStoryboard()
        
        connect.connectRelay
            .flatMap { return self.userRequiresEmailVerification() }
            .subscribe(onNext: { showEmailVerification in
                if showEmailVerification {
                    self.showEmailConfirmationScreen()
                } else {
                    self.syncAddressesAndLaunchPIT()
                }
            }).disposed(by: bag)
        
        connect.learnMoreRelay
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let pitURL = URL(string: "https://pit.blockchain.com") else { return }
                let controller = SFSafariViewController(url: pitURL)
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
        let emailConfirmationScreen = PitEmailVerificationViewController.makeFromStoryboard()
        
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
            self.syncAddressesAndLaunchPIT()
        }
        let action = AlertAction(
            style: .default(LocalizationConstants.PIT.ConnectionPage.Actions.connectNow),
            metadata: .block(block))
        let alert = AlertModel(
            headline: LocalizationConstants.PIT.EmailVerification.verified,
            body: LocalizationConstants.PIT.EmailVerification.verifiedDescription,
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
    
    private func syncAddressesAndLaunchPIT() {
        if isLinkingToExistingPitUser() {
            syncAddressesAndLinkPitToWallet()
        } else {
            syncAddressAndLinkWalletToPit()
        }
    }
    
    private func syncAddressAndLinkWalletToPit() {
        /// Users that have linked their PIT account should be sent to the `/trade`
        /// page and not the PIT landing page. 
        guard let pitURL = URL(string: BlockchainAPI.shared.pitURL + "/trade") else { return }
        repository.syncDepositAddresses()
            .andThen(hasLinkedPITAccount())
            .flatMap(weak: self, { (self, hasLinkedPitAccount) -> Single<URL> in
                return hasLinkedPitAccount ? Single.just(pitURL) : self.authenticator.pitURL
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
    
    private func syncAddressesAndLinkPitToWallet() {
        authenticator.pitLinkID
            .flatMapCompletable(weak: self) { (self, linkID) -> Completable in
                return self.authenticator.linkToExistingPitUser(linkID: linkID)
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
                self.appSettings.pitLinkIdentifier = nil
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    private func hasLinkedPITAccount() -> Single<Bool> {
        return repository.hasLinkedPITAccount
    }
    
    private func isLinkingToExistingPitUser() -> Bool {
        return appSettings.pitLinkIdentifier != nil
    }
    
    // MARK: Lazy Private Properties
    
    private lazy var syncingBottomAlertSheet: BottomAlertSheet = {
        let loading = LoadingBottomAlert(
            title: LocalizationConstants.PIT.Alerts.connectingYou,
            subtitle: LocalizationConstants.PIT.Alerts.newWindow,
            gradient: .pit
        )
        return BottomAlertSheet.make(with: loading)
    }()
    
    private lazy var successfulLinkingBottomSheet: BottomAlertSheet = {
        let success = ThumbnailBottomAlert(
            title: LocalizationConstants.PIT.Alerts.success,
            subtitle: LocalizationConstants.PIT.Alerts.successDescription,
            gradient: .pit,
            thumbnail: #imageLiteral(resourceName: "green-checkmark-bottom-sheet")
        )
        return BottomAlertSheet.make(with: success)
    }()
    
    private lazy var failureLinkingBottomSheet: BottomAlertSheet = {
        let success = ThumbnailBottomAlert(
            title: LocalizationConstants.PIT.Alerts.error,
            subtitle: LocalizationConstants.PIT.Alerts.errorDescription,
            gradient: .pit,
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

