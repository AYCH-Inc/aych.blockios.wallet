//
//  SettingsRouter.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay
import RxCocoa
import SafariServices

protocol SettingRouterAPI: class {
    func handle(selection: SettingsScreenPresenter.Section.CellType)
}

final class SettingsRouter: SettingRouterAPI {
    
    typealias CellType = SettingsScreenPresenter.Section.CellType
    
    private var action: Signal<SettingsScreenAction> {
        return selectionRelay.asSignal().map { $0.action }
    }
    
    private let selectionRelay = PublishRelay<CellType>()
    private let disposeBag = DisposeBag()
    private unowned let currencyRouting: CurrencyRouting
    private unowned let tabSwapping: TabSwapping
    private let guidRepositoryAPI: GuidRepositoryAPI
    private let rootViewController: SettingsViewController
    
    init(rootViewController: SettingsViewController,
         guidRepositoryAPI: GuidRepositoryAPI = WalletManager.shared.repository,
         currencyRouting: CurrencyRouting,
         tabSwapping: TabSwapping) {
        self.rootViewController = rootViewController
        self.currencyRouting = currencyRouting
        self.tabSwapping = tabSwapping
        self.guidRepositoryAPI = guidRepositoryAPI
        
        action
            .emit(onNext: { [weak self] in
                self?.handle(action: $0) }
            )
            .disposed(by: disposeBag)
    }
    
    func handle(selection: CellType) {
        selectionRelay.accept(selection)
    }
    
    private func handle(action: SettingsScreenAction) {
        switch action {
        case .showURL(let url):
            let controller = SFSafariViewController(url: url)
            let navController = BaseNavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .overFullScreen
            rootViewController.present(navController, animated: true, completion: nil)
        case .launchChangePassword:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            guard let controller = storyboard.instantiateViewController(
                withIdentifier: SettingsChangePasswordViewController.objectName
                ) as? SettingsChangePasswordViewController else { return }
            let navController = BCNavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .overFullScreen
            self.rootViewController.present(navController, animated: true, completion: nil)
        case .showAboutScreen:
            AboutUsViewController.present(in: self.rootViewController)
        case .showBackupScreen:
            let backupViewController = BackupFundsViewController(router: self)
            rootViewController.navigationController?.pushViewController(backupViewController, animated: true)
        case .launchWebLogin:
            let webLoginController = WebLoginViewController()
            webLoginController.modalPresentationStyle = .overFullScreen
            let navController = BCNavigationController(rootViewController: webLoginController)
            navController.modalPresentationStyle = .overFullScreen
            self.rootViewController.present(navController, animated: true, completion: nil)
        case .promptGuidCopy:
            guidRepositoryAPI.guid
                .map(weak: self) { (self, value) -> String in
                    return value ?? ""
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] guid in
                    guard let self = self else { return }
                    let alert = UIAlertController(title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                                                  message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                                                  preferredStyle: .actionSheet)
                    let copyAction = UIAlertAction(
                        title: LocalizationConstants.AddressAndKeyImport.copyCTA,
                        style: .destructive,
                        handler: { _ in
                            // TODO: Analytics
                            UIPasteboard.general.string = guid
                        }
                    )
                    let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    alert.addAction(copyAction)
                    self.rootViewController.present(alert, animated: true)
                })
                .disposed(by: disposeBag)
            
        case .launchKYC:
            KYCTiersViewController.routeToTiers(
                fromViewController: self.rootViewController
            ).disposed(by: disposeBag)
        case .launchPIT:
            guard let supportURL = URL(string: Constants.Url.exchangeSupport) else { return }
            let startPITCoordinator = { [weak self] in
                guard let self = self else { return }
                ExchangeCoordinator.shared.start(from: self.rootViewController)
            }
            let launchPIT = AlertAction(
                style: .confirm(LocalizationConstants.Exchange.Launch.launchExchange),
                metadata: .block(startPITCoordinator)
            )
            let contactSupport = AlertAction(
                style: .default(LocalizationConstants.Exchange.Launch.contactSupport),
                metadata: .url(supportURL)
            )
            let model = AlertModel(
                headline: LocalizationConstants.Exchange.title,
                body: nil,
                actions: [launchPIT, contactSupport],
                image: #imageLiteral(resourceName: "pit-icon"),
                dismissable: true,
                style: .sheet
            )
            let alert = AlertView.make(with: model) { [weak self] action in
                guard let self = self else { return }
                guard let metadata = action.metadata else { return }
                switch metadata {
                case .block(let block):
                    block()
                case .url(let support):
                    let controller = SFSafariViewController(url: support)
                    controller.modalPresentationStyle = .overFullScreen
                    self.rootViewController.present(controller, animated: true, completion: nil)
                case .dismiss,
                     .pop,
                     .payload:
                    break
                }
            }
            alert.show()
        case .none:
            break
        }
    }
}

extension SettingsRouter: BackupFundsRouterAPI {
    func startBackup() {
        let recoveryViewController = RecoveryPhraseViewController(router: self)
        rootViewController.navigationController?.pushViewController(recoveryViewController, animated: true)
    }
}

extension SettingsRouter: RecoveryPhraseRouterAPI {
    func verify(mnemonic: [String]) {
        let presenter = VerifyBackupScreenPresenter(mnemonic: mnemonic, router: self)
        let verifyBackupViewController = VerifyBackupViewController(presenter: presenter)
        rootViewController.navigationController?.pushViewController(verifyBackupViewController, animated: true)
    }
}

extension SettingsRouter: VerifyBackupRouterAPI {
    func verificationCompleted() {
        
    }
}
