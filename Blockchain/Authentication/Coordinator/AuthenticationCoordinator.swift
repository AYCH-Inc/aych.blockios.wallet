//
//  AuthenticationCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import PlatformUIKit

@objc class AuthenticationCoordinator: NSObject, Coordinator, VersionUpdateAlertDisplaying {

    @objc static let shared = AuthenticationCoordinator()

    @objc class func sharedInstance() -> AuthenticationCoordinator {
        return shared
    }

    // TODO: Boilerplate for injecting dependencies into `self` instance
    private(set) lazy var alertPresenter = AlertViewPresenter.shared
    private(set) lazy var authenticationManager = AuthenticationManager.shared
    private(set) lazy var appSettings = BlockchainSettings.App.shared
    private(set) lazy var onboardingSettings = BlockchainSettings.Onboarding.shared
    private(set) lazy var wallet = WalletManager.shared.wallet
    private let remoteNotificationTokenSender: RemoteNotificationTokenSending
    private let remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting

    let recorder: ErrorRecording
    let loadingViewPresenter: LoadingViewPresenting

    var postAuthenticationRoute: PostAuthenticationRoute?

    /// Authentication handler - this should not be a property of AuthenticationCoordinator
    /// but the current way wallet creation is designed, we need to share this handler
    /// with that flow. Eventually, wallet creation should be moved with AuthenticationCoordinator
    lazy var authHandler: AuthenticationManager.WalletAuthHandler = { [weak self] isAuthenticated, _, error in
        guard let self = self else { return }

        self.loadingViewPresenter.hide()

        // Error checking
        guard error == nil, isAuthenticated else {
            switch error!.code {
            case AuthenticationError.ErrorCode.noInternet.rawValue:
                self.alertPresenter.showNoInternetConnectionAlert()
            case AuthenticationError.ErrorCode.emailAuthorizationRequired.rawValue:
                self.alertPresenter.showEmailAuthorizationRequired()
            case AuthenticationError.ErrorCode.failedToLoadWallet.rawValue:
                self.handleFailedToLoadWallet()
            case AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue:
                if self.appSettings.guid == nil && WalletManager.shared.wallet.guid != nil {
                    // Attempted to manual pair with incorrect password
                    self.startManualPairing()
                    return
                }
                self.showPasswordModal()
            default:
                if let description = error!.description {
                    self.alertPresenter.standardError(message: description)
                }
            }
            return
        }
        
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
        
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController,
            self.appSettings.isPinSet, !(topViewController is SettingsNavigationController) {
            self.alertPresenter.showMobileNoticeIfNeeded()
        }

        // Handle any necessary routing after authentication
        self.handlePostAuthenticationRouting()
        
        // Enabling touch ID and immediately backgrounding the app hides the status bar
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
    }

    func handlePostAuthenticationRouting() {
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
    let pitRepository: PITAccountRepositoryAPI
    private let bag: DisposeBag = DisposeBag()
    private var pairingCodeParserViewController: UIViewController?

    private var disposable: Disposable?
    // MARK: - Initializer

    init(walletManager: WalletManager = WalletManager.shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         walletService: WalletService = WalletService.shared,
         dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         stellarServiceProvider: StellarServiceProvider = StellarServiceProvider.shared,
         deepLinkRouter: DeepLinkRouter = DeepLinkRouter(),
         recorder: ErrorRecording = CrashlyticsRecorder(),
         remoteNotificationServiceContainer: RemoteNotificationServiceContainer = .default,
         pitRepository: PITAccountRepositoryAPI = PITAccountRepository()) {
        self.walletManager = walletManager
        self.walletService = walletService
        self.dataRepository = dataRepository
        self.stellarServiceProvider = stellarServiceProvider
        self.deepLinkRouter = deepLinkRouter
        self.recorder = recorder
        self.loadingViewPresenter = loadingViewPresenter
        remoteNotificationAuthorizer = remoteNotificationServiceContainer.authorizer
        remoteNotificationTokenSender = remoteNotificationServiceContainer.tokenSender
        self.pitRepository = pitRepository
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
            disposable = walletService.walletOptions
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] walletOptions in
                    guard !walletOptions.downForMaintenance else {
                        self?.alertPresenter.showMaintenanceError(from: walletOptions)
                        return
                    }
                    self?.displayVersionUpdateAlertIfNeeded(for: walletOptions.updateType)
                }, onError: { [weak self] _ in
                    self?.alertPresenter.standardError(message: LocalizationConstants.Errors.requestFailedCheckConnection)
                })
            showPasswordModal()
            AlertViewPresenter.shared.checkAndWarnOnJailbrokenPhones()
        }
        // TODO
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSideMenu)
        // name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
    }

    /// Starts the manual wallet pairing flow
    func startManualPairing() {
        let manualPairView = BCManualPairView.instanceFromNib()
        manualPairView.delegate = self
        ModalPresenter.shared.showModal(
            withContent: manualPairView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.Authentication.manualPairing
        )
    }

    /// Unauthenticates the user
    @objc func logout(showPasswordView: Bool) {
        WalletManager.shared.close()

        dataRepository.clearCache()

        SocketManager.shared.disconnectAll()
        StellarServiceProvider.shared.tearDown()
        appSettings.reset()
        onboardingSettings.reset()
        
        let appCoordinator = AppCoordinator.shared
        appCoordinator.tabControllerManager.clearSendToAddressAndAmountFields()
        appCoordinator.closeSideMenu()
        appCoordinator.reload()

        if showPasswordView {
            showPasswordModal()
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

    // MARK: - PasswordRequiredViewDelegate Presentation

    @objc func showForgetWalletConfirmAlert() {
        let alert = UIAlertController(
            title: LocalizationConstants.Errors.warning,
            message: LocalizationConstants.Authentication.forgetWalletDetail,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { [unowned self] _ in
                Logger.shared.info("Forgetting wallet")
                ModalPresenter.shared.closeModal(withTransition: convertFromCATransitionType(CATransitionType.fade))
                self.walletManager.forgetWallet()
                OnboardingCoordinator.shared.start()
                // TICKET: IOS-1365 - Finish UserDefaults refactor (tickets, documentation, linter issues)
                // BlockchainSettings.App.shared.clear()
            }
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    /// Starts the wallet pairing flow by scanning a QR code
    func startQRCodePairing() {
        pairingCodeParserViewController =
            QRCodeScannerViewControllerBuilder(
                parser: PairingCodeQRCodeParser(),
                textViewModel: PairingCodeQRCodeTextViewModel(),
                completed: { [weak self] result in
                    self?.handlePairingCodeResult(result: result)
                }
            )
            .with(loadingViewPresenter: loadingViewPresenter)
            .build()

        guard let pairingCodeParserViewController = pairingCodeParserViewController else { return }

        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            pairingCodeParserViewController,
            animated: true
        )
    }
    
    private func handlePairingCodeResult(result: Result<PairingCodeQRCodeParser.PairingCode, PairingCodeQRCodeParser.PairingCodeParsingError>) {
        switch result {
        case .success(let pairingCode):
            authenticationManager.authenticate(using: pairingCode.passcodePayload, andReply: authHandler)
        case .failure(let error):
            alertPresenter.standardError(message: error.localizedDescription)
        }
    }
    
    private func showForgotPasswordAlert() {
        let title = String(format: LocalizationConstants.openArg, Constants.Url.blockchainSupport)
        let alert = UIAlertController(
            title: title,
            message: LocalizationConstants.youWillBeLeavingTheApp,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
                guard let url = URL(string: Constants.Url.forgotPassword) else { return }
                UIApplication.shared.open(url)
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    // MARK: - Password Presentation

    // TODO: make private once migrated
    @objc func showPasswordModal() {
        let passwordRequestedView = PasswordRequiredView.instanceFromNib()
        passwordRequestedView.delegate = self
        ModalPresenter.shared.showModal(
            withContent: passwordRequestedView,
            closeType: ModalCloseTypeNone,
            showHeader: true,
            headerText: LocalizationConstants.Authentication.passwordRequired
        )
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
                        OnboardingCoordinator.shared.start()
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

extension AuthenticationCoordinator: ManualPairViewDelegate {
    func manualPairView(_ manualPairView: BCManualPairView!, didContinueWithGuid guid: String!, andPassword password: String!) {
        
        loadingViewPresenter.showCircular(with: LocalizationConstants.Authentication.loadingWallet)

        let payload = PasscodePayload(guid: guid, password: password, sharedKey: "")
        authenticationManager.authenticate(using: payload) { [weak self] isAuthenticated, twoFAtype, error in
            guard let strongSelf = self else { return }
            guard twoFAtype == nil else {
                strongSelf.handle(twoFactorAuthType: twoFAtype!, forManualPairView: manualPairView)
                return
            }
            strongSelf.authHandler(isAuthenticated, twoFAtype, error)
        }
    }

    private func handle(twoFactorAuthType: AuthenticationTwoFactorType, forManualPairView view: BCManualPairView) {
        switch twoFactorAuthType {
        case .google:
            view.verifyTwoFactorGoogle()
        case .yubiKey:
            view.verifyTwoFactorYubiKey()
        case .sms:
            view.verifyTwoFactorSMS()
        default:
            Logger.shared.error("Unhandled 2FA type: \(twoFactorAuthType)")
        }
    }
}

extension AuthenticationCoordinator: PasswordRequiredViewDelegate {
    func didTapForgotPassword() {
        showForgotPasswordAlert()
    }

    func didTapForgetWallet() {
        showForgetWalletConfirmAlert()
    }

    func didContinue(with password: String) {

        // Guard checks before attempting to authenticate
        guard let guid = appSettings.guid,
            let sharedKey = appSettings.sharedKey else {
            alertPresenter.showKeychainReadError()
            return
        }

        let payload = PasscodePayload(guid: guid, password: password, sharedKey: sharedKey)
        authenticationManager.authenticate(using: payload, andReply: authHandler)
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
