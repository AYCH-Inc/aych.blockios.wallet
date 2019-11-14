//
//  AuthenticationCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import BitcoinKit
import PlatformKit
import PlatformUIKit

/// Any action related to authentication should go here
enum AuthenticationAction {
    
    /// Email verification
    case verifyEmail

}

/// An authentication service API for manual pairing
protocol ManualPairingServiceAPI: class {
    var action: Observable<AuthenticationAction> { get }
    func authenticate(with guid: String,
                      password: String,
                      twoFAHandler: @escaping (AuthenticationTwoFactorType) -> Void)
}

@objc class AuthenticationCoordinator: NSObject, Coordinator, VersionUpdateAlertDisplaying {

    @objc static let shared = AuthenticationCoordinator()

    @objc class func sharedInstance() -> AuthenticationCoordinator {
        return shared
    }

    // TODO: Boilerplate for injecting dependencies into `self` instance
    private(set) lazy var alertPresenter = AlertViewPresenter.shared
    let authenticationManager: AuthenticationManager
    private(set) lazy var appSettings = BlockchainSettings.App.shared
    private(set) lazy var onboardingSettings = BlockchainSettings.Onboarding.shared
    private(set) lazy var wallet = WalletManager.shared.wallet
    private let remoteNotificationTokenSender: RemoteNotificationTokenSending
    private let remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting

    let recorder: ErrorRecording
    
    /// Keeps state of email validation during the onboarding - remove this when refactoring
    var isWaitingForEmailValidation = false
    
    let loadingViewPresenter: LoadingViewPresenting

    var postAuthenticationRoute: PostAuthenticationRoute?

    let actionRelay = PublishRelay<AuthenticationAction>()
    var action: Observable<AuthenticationAction> {
        return actionRelay.asObservable()
    }
        
    /// Authentication handler - this should not be a property of AuthenticationCoordinator
    /// but the current way wallet creation is designed, we need to share this handler
    /// with that flow. Eventually, wallet creation should be moved with AuthenticationCoordinator
    @available(*, deprecated, message: "This method is deprected and its logic should be distributed to separate services")
    lazy var authHandler: AuthenticationManager.WalletAuthHandler = { [weak self] isAuthenticated, _, error in
        guard let self = self else { return }

        self.loadingViewPresenter.hide()
        
        /// TODO: Temporarily here
        self.isWaitingForEmailValidation = false
        
        // Error checking
        guard error == nil, isAuthenticated else {
            switch error!.code {
            case AuthenticationError.ErrorCode.noInternet.rawValue:
                self.alertPresenter.showNoInternetConnectionAlert()
            case AuthenticationError.ErrorCode.emailAuthorizationRequired.rawValue:
                self.actionRelay.accept(.verifyEmail)
            case AuthenticationError.ErrorCode.failedToLoadWallet.rawValue:
                self.handleFailedToLoadWallet()
            case AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue:
                if self.appSettings.guid == nil && WalletManager.shared.wallet.guid != nil {
                    return
                }
                self.showPasswordViewController()
            default:
                if let description = error!.description {
                    self.alertPresenter.standardError(message: description)
                }
            }
            return
        }
        
        let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController
        topViewController?.dismiss(animated: true, completion: nil)
        
        ModalPresenter.shared.closeAllModals()

        let tabControllerManager = AppCoordinator.shared.tabControllerManager
        tabControllerManager.sendBitcoinViewController?.reload()
        tabControllerManager.sendBitcoinCashViewController?.reload()

        self.dataRepository.prefetchData()
        self.stellarServiceProvider.services.accounts.prefetch()
        
        // Make user set up a pin if none is set. They can also optionally enable touch ID and link their email.
        guard self.appSettings.isPinSet else {
            self.showPinEntryView()
            return
        }
        
        /// If the user has linked to the PIT, we sync their addresses on authentication.
        self.pitRepository.syncDepositAddressesIfLinked()
            .subscribe()
            .disposed(by: self.bag)
        
        // TODO: Relocate notification permissions according to the new design
        self.remoteNotificationTokenSender.sendTokenIfNeeded()
            .subscribe()
            .disposed(by: self.bag)
        self.remoteNotificationAuthorizer.requestAuthorizationIfNeeded()
            .subscribe()
            .disposed(by: self.bag)
        
        if let topViewController = topViewController,
            self.appSettings.isPinSet, !(topViewController is SettingsNavigationController) {
            self.alertPresenter.showMobileNoticeIfNeeded()
        }
        
        /// Sliding view controller must be the root at the end of authentication, password required can be displayed as modal
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = AppCoordinator.shared.slidingViewController

        // Handle any necessary routing after authentication
        self.handlePostAuthenticationLogic()
    }
    
    func handlePostAuthenticationLogic() {
        // Handle STX Airdrop registration
        self.blockstackService.registerForCampaignIfNeeded
            .subscribe()
            .disposed(by: self.bag)
        
        if let route = postAuthenticationRoute {
            switch route {
            case .sendCoins:
                AppCoordinator.shared.tabControllerManager.showSendCoins(animated: true)
            }
            postAuthenticationRoute = nil
        }

        // Handle airdrop routing
        deepLinkRouter.routeIfNeeded()
    }

    let dataRepository: BlockchainDataRepository
    let stellarServiceProvider: StellarServiceProvider
    let walletManager: WalletManager
    private let walletService: WalletService

    var pinRouter: PinRouter!
    private let deepLinkRouter: DeepLinkRouter
    private let analyticsRecorder: AnalyticsEventRecording
    private let pitRepository: PITAccountRepositoryAPI
    private let blockstackService: BlockstackServiceAPI
    private let bag: DisposeBag = DisposeBag()
    private var pairingCodeParserViewController: UIViewController?

    private var disposable: Disposable?
    // MARK: - Initializer

    init(authenticationManager: AuthenticationManager = .shared,
         walletManager: WalletManager = WalletManager.shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         walletService: WalletService = WalletService.shared,
         dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         stellarServiceProvider: StellarServiceProvider = StellarServiceProvider.shared,
         deepLinkRouter: DeepLinkRouter = DeepLinkRouter(),
         recorder: ErrorRecording = CrashlyticsRecorder(),
         remoteNotificationServiceContainer: RemoteNotificationServiceContainer = .default,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         pitRepository: PITAccountRepositoryAPI = PITAccountRepository(),
         blockstackService: BlockstackServiceAPI = BlockstackService()) {
        self.authenticationManager = authenticationManager
        self.walletManager = walletManager
        self.walletService = walletService
        self.dataRepository = dataRepository
        self.stellarServiceProvider = stellarServiceProvider
        self.deepLinkRouter = deepLinkRouter
        self.recorder = recorder
        self.analyticsRecorder = analyticsRecorder
        self.loadingViewPresenter = loadingViewPresenter
        remoteNotificationAuthorizer = remoteNotificationServiceContainer.authorizer
        remoteNotificationTokenSender = remoteNotificationServiceContainer.tokenSender
        self.pitRepository = pitRepository
        self.blockstackService = blockstackService
        super.init()
        self.walletManager.secondPasswordDelegate = self
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: - Start Flows

    /// Starts the authentication flow. If the user has a pin set, it will trigger
    /// present the pin entry screen, otherwise, it will show the password screen.
    @objc func start() {
        if appSettings.isPinSet {
            authenticatePin()
        } else {
            showPasswordViewController()
        }
    }
    
    /// Unauthenticates the user
    @objc func logout(showPasswordView: Bool) {
        WalletManager.shared.close()

        dataRepository.clearCache()

        SocketManager.shared.disconnectAll()
        StellarServiceProvider.shared.tearDown()
        appSettings.reset()
        onboardingSettings.reset()
        
        AppCoordinator.shared.tabControllerManager.clearSendToAddressAndAmountFields()
        AppCoordinator.shared.closeSideMenu()
        AppCoordinator.shared.reload()

        if showPasswordView {
            showPasswordViewController()
        }
    }

    /// Cleanup any running authentication flows when the app is backgrounded.
    func cleanupOnAppBackgrounded() {
        guard let pinRouter = pinRouter,
            pinRouter.isBeingDisplayed,
            !pinRouter.flow.isLoginAuthentication else {
            return
        }
        pinRouter.cleanup()
    }

    // MARK: - Password Presentation

    @objc func showPasswordViewController() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let presenter = PasswordRequiredScreenPresenter()
        let viewController = PasswordRequiredViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
    }

    /// Displays a view (modal) requesting the user to enter their password.
    ///
    /// - Parameters:
    ///   - displayText: the display/description text in the view presented to the user
    ///   - headertext: the header text to display on the presented modal
    ///   - validateSecondPassword: if the password should be validated against the wallet password
    ///   - handler: completion handler invoked when the user confirms their password
    @objc func showPasswordConfirm(
        withDisplayText displayText: String,
        headerText: String,
        validateSecondPassword: Bool,
        confirmHandler: @escaping PasswordConfirmView.OnPasswordConfirmHandler,
        dismissHandler: PasswordConfirmView.OnPasswordDismissHandler? = nil
    ) {
        loadingViewPresenter.hide()

        let passwordConfirmView = PasswordConfirmView.instanceFromNib()
        passwordConfirmView.updateLabelDescription(text: displayText)
        passwordConfirmView.validateSecondPassword = validateSecondPassword
        passwordConfirmView.confirmHandler = { [unowned self] password in
            guard password.count > 0 else {
                self.alertPresenter.standardError(message: LocalizationConstants.Authentication.noPasswordEntered)
                return
            }

            guard !passwordConfirmView.validateSecondPassword || self.walletManager.wallet.validateSecondPassword(password) else {
                self.alertPresenter.standardError(message: LocalizationConstants.Authentication.secondPasswordIncorrect)
                return
            }

            ModalPresenter.shared.closeModal(withTransition: convertFromCATransitionType(CATransitionType.fade))
            confirmHandler(password)
        }
        passwordConfirmView.dismissHandler = dismissHandler
        ModalPresenter.shared.showModal(
            withContent: passwordConfirmView,
            closeType: ModalCloseTypeClose,
            showHeader: true,
            headerText: headerText
        )

        passwordConfirmView.showKeyboard()
    }

    // MARK: - Private

    private func handleFailedToLoadWallet() {
        guard let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else {
            return
        }

        let alertController = UIAlertController(
            title: LocalizationConstants.Authentication.failedToLoadWallet,
            message: LocalizationConstants.Authentication.failedToLoadWalletDetail,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { _ in

                let forgetWalletAlert = UIAlertController(
                    title: LocalizationConstants.Errors.warning,
                    message: LocalizationConstants.Authentication.forgetWalletDetail,
                    preferredStyle: .alert
                )
                forgetWalletAlert.addAction(
                    UIAlertAction(title: LocalizationConstants.cancel, style: .cancel) { [unowned self] _ in
                        self.handleFailedToLoadWallet()
                    }
                )
                forgetWalletAlert.addAction(
                    UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { [unowned self] _ in
                        self.walletManager.forgetWallet()
                        AppCoordinator.shared.onboardingRouter.start(in: UIApplication.shared.keyWindow!)
                    }
                )
                topMostViewController.present(forgetWalletAlert, animated: true)
            }
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { _ in
                UIApplication.shared.suspendApp()
            }
        )
        topMostViewController.present(alertController, animated: true)
    }
}

extension AuthenticationCoordinator: ManualPairingServiceAPI {
    func authenticate(with guid: String,
                      password: String,
                      twoFAHandler: @escaping (AuthenticationTwoFactorType) -> Void) {
        loadingViewPresenter.showCircular(with: LocalizationConstants.Authentication.loadingWallet)
        let payload = PasscodePayload(guid: guid, password: password, sharedKey: "")
        authenticationManager.authenticate(using: payload) { [weak self] isAuthenticated, twoFA, error in
            guard let self = self else { return }
            if let twoFA = twoFA {
                twoFAHandler(twoFA)
            } else {
                self.authHandler(isAuthenticated, twoFA, error)
            }
        }
    }
}

extension AuthenticationCoordinator: WalletSecondPasswordDelegate {
    func getSecondPassword(success: WalletSuccessCallback, dismiss: WalletDismissCallback?) {
        showPasswordConfirm(withDisplayText: LocalizationConstants.Authentication.secondPasswordDefaultDescription,
                            headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                            validateSecondPassword: true,
                            confirmHandler: { (secondPassword) in
                                success.success(string: secondPassword)
                            },
                            dismissHandler: { dismiss?.dismiss() }
        )
    }

    func getPrivateKeyPassword(success: WalletSuccessCallback) {
        showPasswordConfirm(withDisplayText: LocalizationConstants.Authentication.privateKeyPasswordDefaultDescription,
                            headerText: LocalizationConstants.Authentication.privateKeyNeeded,
                            validateSecondPassword: false,
                            confirmHandler: { (privateKeyPassword) in
                                success.success(string: privateKeyPassword)
                            }
        )
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
	return input.rawValue
}
