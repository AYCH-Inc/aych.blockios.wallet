//
//  OnboardingRouter.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

/// An agnostic routing starter
protocol RouteStarting: class {
    
    /// Expected to route to the start of the flow
    func start()
}

/// An agnostic routing ender
protocol RouteEnding: class {
    
    /// Expected to route to the end of the flow
    /// Usually that means, starting a new flow by calling
    /// on another dependant router `func start()`
    func end()
}

/// Router for the onboarding flow.
final class OnboardingRouter: VersionUpdateAlertDisplaying {
                
    // MARK: - Navigation
    
    /// Onboarding navigation controller.
    /// Should be retained weakly and nullified after `navigationController`
    /// is replaced by the next root
    private weak var navigationController: UINavigationController!
    
    // MARK: - Injected
    
    private let webViewServiceAPI: WebViewServiceAPI
    
    // MARK: - Accessors
    
    private let bag = DisposeBag()

    // MARK: - Setup
    
    init(webViewServiceAPI: WebViewServiceAPI = UIApplication.shared) {
        self.webViewServiceAPI = webViewServiceAPI
    }
    
    // MARK: API

    /// A single entry point to the beginning of the onboarding
    func start(in window: UIWindow = UIApplication.shared.keyWindow!) {
        showWelcomeScreen(in: window)
    }
    
    // MARK: - Welcome
    
    private func showWelcomeScreen(in window: UIWindow) {
        let presenter = WelcomeScreenPresenter()
        presenter.createTapRelay
            .bind { [weak self] _ in
                self?.navigateToCreateWalletScreen()
            }
            .disposed(by: bag)
        presenter.loginTapRelay
            .bind { [weak self] _ in
                self?.navigateToPairingIntroScreen()
            }
            .disposed(by: bag)
        presenter.recoverFundsTapRelay
            .bind { [weak self] _ in
                self?.navigateToRecoverFundsScreen()
            }
            .disposed(by: bag)
        let viewController = WelcomeViewController(presenter: presenter)
        
        /// Mount the navigation controller as the `rootViewController` of the window
        let navigationController = NavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        self.navigationController = navigationController
    }
    
    // MARK: - Create Wallet
    
    private func navigateToCreateWalletScreen() {
        let interactor = CreateWalletScreenInteractor()
        let presenter = RegisterWalletScreenPresenter(interactor: interactor)
        presenter.webViewLaunchRelay
            .bind { [weak self] url in
                guard let self = self else { return }
                self.webViewServiceAPI.openSafari(url: url, from: self.navigationController)
            }
            .disposed(by: bag)
        let viewController = RegisterWalletViewController(presenter: presenter)
        navigate(to: viewController)
    }
    
    // MARK: - Recover Funds
    
    private func navigateToRecoverFundsScreen() {
        let presenter = RecoverFundsScreenPresenter()
        presenter.continueTappedRelay
            .bind { [weak self] mnemonic in
                self?.navigateToCreateRecoveryWalletScreen(mnemonic)
        }
        .disposed(by: bag)
        let controller = RecoverFundsViewController(presenter: presenter)
        
        navigate(to: controller)
    }
    
    private func navigateToCreateRecoveryWalletScreen(_ mnemonic: String) {
        let interactor = RecoverWalletScreenInteractor(passphrase: mnemonic)
        let presenter = RegisterWalletScreenPresenter(interactor: interactor, type: .recovery)
        presenter.webViewLaunchRelay
            .bind { [weak self] url in
                guard let self = self else { return }
                self.webViewServiceAPI.openSafari(url: url, from: self.navigationController)
            }
            .disposed(by: bag)
        let viewController = RegisterWalletViewController(presenter: presenter)
        navigate(to: viewController)
    }
    
    // MARK: - Pairing
    
    private func navigateToPairingIntroScreen() {
        let presenter = PairingIntroScreenPresenter()
        presenter.autoPairingNavigationRelay
            .bind { [weak self] in
                self?.navigateToAutoPairingScreen()
            }
            .disposed(by: bag)
        presenter.manualPairingNavigationRelay
            .bind { [weak self] in
                self?.navigateToManualPairingScreen()
            }
            .disposed(by: bag)
        let viewController = PairingIntroViewController(presenter: presenter)
        navigate(to: viewController)
    }
    
    private func navigateToAutoPairingScreen() {
        let presenter = AutoPairingScreenPresenter()
        let viewController = AutoPairingViewController(presenter: presenter)
        navigate(to: viewController)
    }
    
    func navigateToManualPairingScreen() {
        let presenter = ManualPairingScreenPresenter()
        let viewController = ManualPairingViewController(presenter: presenter)
        navigate(to: viewController)
    }
    
    // MARK: - Additional Accessories
    
    private func navigate(to viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension OnboardingRouter: WalletRecoveryDelegate {
    func didRecoverWallet() {
//        createWallet?.didRecoverWallet()
    }

    func didFailRecovery() {
//        createWallet?.showPassphraseTextField()
    }
}

