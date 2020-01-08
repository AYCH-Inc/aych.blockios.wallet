//
//  AuthenticationCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import NetworkKit
import PlatformKit
import PlatformUIKit

protocol ManualPairingWalletFetching: class {
    func authenticate(using password: String)
}

extension AuthenticationCoordinator: ManualPairingWalletFetching {
    /// A new method for fetching wallet - is being used after manual pairing
    /// TODO: Remove once done migrating JS to native
    func authenticate(using password: String) {
        loadingViewPresenter.showCircular()
        temporaryAuthHandler = authenticationHandler
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.walletManager.wallet.fetch(with: password)
        }
    }
}

@objc class AuthenticationCoordinator: NSObject, Coordinator, VersionUpdateAlertDisplaying {

    // MARK: - Types
    
    typealias WalletAuthHandler = (_ authenticated: Bool, _
                                   twoFactorType: AuthenticatorType?, _
                                   error: AuthenticationError?) -> Void
    
    @objc static let shared = AuthenticationCoordinator()

    @objc class func sharedInstance() -> AuthenticationCoordinator {
        return shared
    }
    
    var postAuthenticationRoute: PostAuthenticationRoute?
    
    private var pinRouter: PinRouter!
    
    private let appSettings: BlockchainSettings.App
    private let onboardingSettings: BlockchainSettings.Onboarding
    private let wallet: Wallet
    private let remoteNotificationTokenSender: RemoteNotificationTokenSending
    private let remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting
        
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    private let dataRepository: BlockchainDataRepository
    private let stellarServiceProvider: StellarServiceProvider
    private let walletManager: WalletManager
    
    private lazy var walletPayloadService = WalletPayloadService(
        client: WalletPayloadClient(),
        repository: walletManager.repository
    )
    
    private let deepLinkRouter: DeepLinkRouter
    private let exchangeRepository: ExchangeAccountRepositoryAPI
        
    /// TODO: Delete when `AuthenticationCoordinator` is removed
    /// Temporary handler since `AuthenticationManager` was refactored.
    var temporaryAuthHandler: WalletAuthHandler!
    
    /// TODO: Delete when `AuthenticationCoordiantor` is removed and
    /// `PasswordViewController` had it's own router.
    var hasFinishedAuthentication = false
    var isShowingSecondPasswordScreen = false
    
    private let bag = DisposeBag()
        
   // MARK: - Initializer

   init(appSettings: BlockchainSettings.App = .shared,
        onboardingSettings: BlockchainSettings.Onboarding = .shared,
        wallet: Wallet = WalletManager.shared.wallet,
        alertPresenter: AlertViewPresenter = AlertViewPresenter.shared,
        walletManager: WalletManager = WalletManager.shared,
        loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
        dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
        stellarServiceProvider: StellarServiceProvider = StellarServiceProvider.shared,
        deepLinkRouter: DeepLinkRouter = DeepLinkRouter(),
        remoteNotificationServiceContainer: RemoteNotificationServiceContainer = .default,
        exchangeRepository: ExchangeAccountRepositoryAPI = ExchangeAccountRepository()) {
       self.appSettings = appSettings
       self.onboardingSettings = onboardingSettings
       self.wallet = wallet
       self.alertPresenter = alertPresenter
       self.walletManager = walletManager
       self.dataRepository = dataRepository
       self.stellarServiceProvider = stellarServiceProvider
       self.deepLinkRouter = deepLinkRouter
       self.loadingViewPresenter = loadingViewPresenter
       remoteNotificationAuthorizer = remoteNotificationServiceContainer.authorizer
       remoteNotificationTokenSender = remoteNotificationServiceContainer.tokenSender
       self.exchangeRepository = exchangeRepository
       super.init()
       self.walletManager.secondPasswordDelegate = self
       self.walletManager.authDelegate = self
    }
    
    /// Authentication handler - this should not be in AuthenticationCoordinator
    /// but the current way wallet creation is designed, we need to share this handler
    /// with that flow. Eventually, wallet creation should be moved with AuthenticationCoordinator
    @available(*, deprecated, message: "This method is deprected and its logic should be distributed to separate services")
    func authenticationHandler(_ isAuthenticated: Bool,
                               _ twoFactorType: AuthenticatorType?,
                               _ error: AuthenticationError?) {
        defer {
            self.loadingViewPresenter.hide()
        }

        // Error checking
        guard error == nil, isAuthenticated else {
            switch error!.code {
            case AuthenticationError.ErrorCode.noInternet.rawValue:
                alertPresenter.showNoInternetConnectionAlert()
            case AuthenticationError.ErrorCode.failedToLoadWallet.rawValue:
                handleFailedToLoadWallet()
            default:
                if let description = error!.description {
                    alertPresenter.standardError(message: description)
                }
            }
            return
        }
        
        alertPresenter.dismissIfNeeded()
        let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController
        
        let tabControllerManager = AppCoordinator.shared.tabControllerManager
        tabControllerManager.sendBitcoinViewController?.reload()
        tabControllerManager.sendBitcoinCashViewController?.reload()

        dataRepository.prefetchData()
        stellarServiceProvider.services.accounts.prefetch()
        
        // Make user set up a pin if none is set. They can also optionally enable touch ID and link their email.
        guard appSettings.isPinSet else {
            showPinEntryView()
            return
        }
        
        /// If the user has linked to the Exchange, we sync their addresses on authentication.
        exchangeRepository.syncDepositAddressesIfLinked()
            .subscribe()
            .disposed(by: bag)
        
        // TODO: Relocate notification permissions according to the new design
        remoteNotificationTokenSender.sendTokenIfNeeded()
            .subscribe()
            .disposed(by: bag)
        remoteNotificationAuthorizer.requestAuthorizationIfNeeded()
            .subscribe()
            .disposed(by: bag)
        
        if let topViewController = topViewController,
            self.appSettings.isPinSet, !(topViewController is SettingsNavigationController) {
            self.alertPresenter.showMobileNoticeIfNeeded()
        }
        
        UIApplication.shared.keyWindow?.rootViewController = AppCoordinator.shared.slidingViewController

        // Handle any necessary routing after authentication
        handlePostAuthenticationLogic()
    }

    func handlePostAuthenticationLogic() {
        if let route = postAuthenticationRoute {
            switch route {
            case .sendCoins:
                AppCoordinator.shared.tabControllerManager.showSendCoins(animated: true)
            }
            postAuthenticationRoute = nil
        }

        // Handle airdrop routing
        deepLinkRouter.routeIfNeeded()
        
        hasFinishedAuthentication = true
    }

    // MARK: - Start Flows

    /// Starts the authentication flow. If the user has a pin set, it will trigger
    /// present the pin entry screen, otherwise, it will show the password screen.
    @objc func start() {
        if appSettings.isPinSet {
            authenticatePin()
        } else {
            showPasswordRequiredViewController()
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
            showPasswordRequiredViewController()
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

    @objc func showPasswordRequiredViewController() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let presenter = PasswordRequiredScreenPresenter()
        let viewController = PasswordRequiredViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
    }
    
    ///   - type: The type of the screen
    ///   - confirmHandler: Confirmation handler, receives the password
    ///   - dismissHandler: Dismiss handler (optional - defaults to `nil`)
    func showPasswordScreen(type: PasswordScreenType,
                            confirmHandler: @escaping PasswordScreenPresenter.ConfirmHandler,
                            dismissHandler: PasswordScreenPresenter.DismissHandler? = nil) {
        guard hasFinishedAuthentication else { return }
        guard !isShowingSecondPasswordScreen else { return }
        guard let parent = UIApplication.shared.topMostViewController else {
            return
        }
        isShowingSecondPasswordScreen = true
        
        let navigationController = UINavigationController()
        
        let confirm: PasswordScreenPresenter.ConfirmHandler = { [weak navigationController] password in
            navigationController?.dismiss(animated: true) {
                confirmHandler(password)
            }
        }
        
        let dismiss: PasswordScreenPresenter.DismissHandler = { [weak navigationController] in
            navigationController?.dismiss(animated: true) {
                dismissHandler?()
            }
        }
        
        loadingViewPresenter.hide()
        let interactor = PasswordScreenInteractor(type: type)
        let presenter = PasswordScreenPresenter(
            interactor: interactor,
            confirmHandler: confirm,
            dismissHandler: dismiss
        )
        let viewController = PasswordViewController(presenter: presenter)
        navigationController.viewControllers = [viewController]
        parent.present(navigationController, animated: true, completion: nil)
    }

    /// ObjC compatible version of `showPasswordScreen`
    @objc func showPasswordScreen(confirmHandler: @escaping PasswordScreenPresenter.ConfirmHandler,
                                  dismissHandler: PasswordScreenPresenter.DismissHandler? = nil) {
        showPasswordScreen(
            type: .actionRequiresPassword,
            confirmHandler: confirmHandler,
            dismissHandler: dismissHandler
        )
    }

}

// MARK: - WalletSecondPasswordDelegate

extension AuthenticationCoordinator: WalletSecondPasswordDelegate {
    func getSecondPassword(success: WalletSuccessCallback, dismiss: WalletDismissCallback?) {
        showPasswordScreen(
            type: .actionRequiresPassword,
            confirmHandler: {
                success.success(string: $0)
            },
            dismissHandler: {
                dismiss?.dismiss()
            }
        )
    }
    
    func getPrivateKeyPassword(success: WalletSuccessCallback) {
        showPasswordScreen(
            type: .importPrivateKey,
            confirmHandler: {
                success.success(string: $0)
            }
        )
    }
}

extension AuthenticationCoordinator: WalletAuthDelegate {
    func didDecryptWallet(guid: String?, sharedKey: String?, password: String?) {

        // Verify valid GUID and sharedKey
        guard let guid = guid, guid.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            ))
            return
        }

        guard let sharedKey = sharedKey, sharedKey.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey.rawValue,
                description: LocalizationConstants.Authentication.invalidSharedKey
            ))
            return
        }

        appSettings.guid = guid
        appSettings.sharedKey = sharedKey

        clearPinIfNeeded(for: password)
    }

    private func clearPinIfNeeded(for password: String?) {
        // Because we are not storing the password on the device. We record the first few letters of the hashed password.
        // With the hash prefix we can then figure out if the password changed. If so, clear the pin
        // so that the user can reset it
        guard let password = password,
            let passwordPartHash = password.passwordPartHash,
            let savedPasswordPartHash = appSettings.passwordPartHash else {
                return
        }

        guard passwordPartHash != savedPasswordPartHash else {
            return
        }

        BlockchainSettings.App.shared.clearPin()
    }

    func authenticationError(error: AuthenticationError?) {
        failAuth(withError: error)
    }

    func authenticationCompleted() {
        temporaryAuthHandler(true, nil, nil)
    }

    private func failAuth(withError error: AuthenticationError? = nil) {
        temporaryAuthHandler(false, nil, error)
    }
    
    // MARK: - Authentication with Passcode

    func authenticate(using payload: PasscodePayload) {
        hasFinishedAuthentication = false
        authenticate(using: payload, authHandler: authenticationHandler)
    }
    
    /**
     The function used to authenticate the user using a provided passcode.
     - Parameters:
        - payload: The passcode payload used for authenticating the user.
        - authHandler: The completion handler for the authentication
     */
    func authenticate(using payload: PasscodePayload,
                      authHandler: @escaping WalletAuthHandler) {
        guard Reachability.hasInternetConnection() else {
            authHandler(false, nil, AuthenticationError(code: AuthenticationError.ErrorCode.noInternet.rawValue))
            return
        }

        guard payload.password.isEmpty == false else {
            authHandler(false, nil, AuthenticationError(
                code: AuthenticationError.ErrorCode.noPassword.rawValue,
                description: LocalizationConstants.Authentication.noPasswordEntered
            ))
            return
        }

        temporaryAuthHandler = authHandler
        
        loadingViewPresenter.showCircular(with: LocalizationConstants.Authentication.loadingWallet)

        walletManager.wallet.load(withGuid: payload.guid, sharedKey: payload.sharedKey, password: payload.password)
    }
}

// MARK: - Pin Authentication

/// Used as a gateway to abstract any pin related login
extension AuthenticationCoordinator {

    /// Returns `true` in case the login pin screen is displayed
    @objc var isDisplayingLoginAuthenticationFlow: Bool {
        return pinRouter?.isDisplayingLoginAuthentication ?? false
    }
    
    /// Change existing pin code. Used from settings mostly.
    func changePin() {
        let logout = { [weak self] () -> Void in
            self?.logout(showPasswordView: true)
        }
        let parentViewController = UIApplication.shared.topMostViewController!
        let boxedParent = UnretainedContentBox(parentViewController)
        let flow = PinRouting.Flow.change(parent: boxedParent, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow)
        pinRouter.execute()
    }
    
    /// Create a new pin code. Used during onboarding, when the user is required to define a pin code before entering his wallet.
    func createPin() {
        let parentViewController = UIApplication.shared.topMostViewController!
        let boxedParent = UnretainedContentBox(parentViewController)
        let flow = PinRouting.Flow.create(parent: boxedParent)
        pinRouter = PinRouter(flow: flow) { [weak self] _ in
            guard let self = self else { return }
            self.alertPresenter.showMobileNoticeIfNeeded()
            /// TODO: Inject app coordinator instead - currently there is
            /// a crash related to circle-dependency between `AuthenticationCoordinator`
            /// and `AppCoordinator`.
            AppCoordinator.shared.startAfterWalletCreation()
            self.handlePostAuthenticationLogic()
        }
        pinRouter.execute()
    }

    /// Authenticate using a pin code. Used during login when the app enters active state.
    func authenticatePin() {
        // If already authenticating, skip this as the screen is already presented
        guard pinRouter == nil || !pinRouter.isDisplayingLoginAuthentication else {
            return
        }
        let logout = { [weak self] () -> Void in
            self?.logout(showPasswordView: true)
        }
        let flow = PinRouting.Flow.authenticate(from: .background, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.authenticate(using: password)
        }
        pinRouter.execute()
    }
    
    /// Validates pin for any in-app flow, for example: enabling touch-id/face-id auth.
    func enableBiometrics() {
        let logout = { [weak self] () -> Void in
            self?.logout(showPasswordView: true)
        }
        let parentViewController = UIApplication.shared.topMostViewController!
        let boxedParent = UnretainedContentBox(parentViewController)
        let flow = PinRouting.Flow.enableBiometrics(parent: boxedParent, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.authenticate(using: password)
        }
        pinRouter.execute()
    }
    
    // TODO: Dump this in favor of using one of the new gateways to PIN flow.
    /// Shows the pin entry view.
    func showPinEntryView() {
        if walletManager.didChangePassword {
            showPasswordRequiredViewController()
        } else if appSettings.isPinSet {
            authenticatePin()
        } else {
            createPin()
        }
    }
}

// TODO: Move out of `AuthenticationCoordinator`
extension AuthenticationCoordinator {
    // MARK: - Private

    private func handleFailedToLoadWallet() {
        guard let topMostViewController = UIApplication.shared.topMostViewController else {
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
