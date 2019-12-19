//
//  ManualPairingInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit

/// Interaction object for manual pairing flow
final class ManualPairingInteractor {
                
    enum AuthenticationType {
        
        /// Standard auth using guid (wallet identifier) and password
        case standard
        
        /// Special auth using guid (wallet identifier), password and one time 2FA string
        case twoFA(String)
    }
    
    /// Any action related to authentication should go here
    enum AuthenticationAction {

        /// Authorize login by approving a message sent by email
        case authorizeLoginWithEmail
        
        /// Authorize login by inserting an OTP code
        case authorizeLoginWith2FA(AuthenticatorType)

        /// Wrong OTP code
        case wrongOtpCode(type: AuthenticatorType, attemptsLeft: Int)
        
        /// Account is locked
        case lockedAccount
        
        /// Some error that should be reflected to the user
        case message(String)
        
        case error(Error)
    }
    
    /// The state of the interaction layer
    struct Content {
        var walletIdentifier = ""
        var password = ""
    }
    
    // MARK: - Properties
    
    let contentStateRelay = BehaviorRelay<Content>(value: Content())
    var content: Observable<Content> {
        return contentStateRelay.asObservable()
    }
    
    var authenticationAction: Observable<AuthenticationAction> {
        return authenticationActionRelay.asObservable()
    }
        
    // MARK: - Properties
    
    let dependencies: Dependencies
        
    private let authenticationActionRelay = PublishRelay<AuthenticationAction>()
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }
    
    // MARK: - API
    
    func pair(using action: AuthenticationType = .standard) throws {
        dependencies.analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletManualLogin)
        
        /// We have to call `loadJS` before starting the pairing process
        /// `true` is being sent because we only need to load the JS.
        dependencies.wallet.loadJSIfNeeded()
        
        let walletIdentifier = contentStateRelay.value.walletIdentifier
        dependencies.sessionTokenService.setupSessionToken()
            .subscribe(
                onCompleted: { [weak self] in
                    self?.authenticate(
                        walletIdentifier: walletIdentifier,
                        action: action
                    )
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.dependencies.errorRecorder.error(error)
                    self.authenticationActionRelay.accept(.error(error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Requests OTP via SMS
    func requestOTPMessage() -> Completable {
        return dependencies.smsService.request()
    }
    
    // MARK: - Accessors
    
    /// Invokes the login service
    private func authenticate(walletIdentifier: String, action: AuthenticationType) {
        let login: Completable
        switch action {
        case .standard:
            login = dependencies.loginService.login(
                walletIdentifier: walletIdentifier
            )
        case .twoFA(let code):
            login = dependencies.loginService.login(
                walletIdentifier: walletIdentifier,
                code: code
            )
        }
        login
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self = self else { return }
                    /// TODO: Continue refactoring wallet fetching logic
                    /// by removing `walletFetcher` reference in favor of a dedicated
                    /// Rx based service.
                    self.dependencies.walletFetcher.authenticate(
                        using: self.contentStateRelay.value.password
                    )
                },
                onError: { [weak self] error in
                    self?.handleAuthentication(error: error)
                }
            )
            .disposed(by: disposeBag)
    }
        
    /// Handles any authentication error by streaming it to the relay
    private func handleAuthentication(error: Error) {
        switch error {
        case LoginService.ServiceError.twoFactorOTPRequired(let type):
            switch type {
            case .email:
                authenticationActionRelay.accept(.authorizeLoginWithEmail)
            default:
                authenticationActionRelay.accept(.authorizeLoginWith2FA(type))
            }
        case LoginService.ServiceError.wrongCode(type: let type, attemptsLeft: let attempts):
            authenticationActionRelay.accept(.wrongOtpCode(type: type, attemptsLeft: attempts))
        case LoginService.ServiceError.accountLocked:
            authenticationActionRelay.accept(.lockedAccount)
        case LoginService.ServiceError.message(let message):
            authenticationActionRelay.accept(.message(message))
        default:
            authenticationActionRelay.accept(.error(error))
        }
    }
}

// MARK: - Dependencies

extension ManualPairingInteractor {
    
    struct Dependencies {
        
        // MARK: - Pairing dependencies
        
        let emailAuthorizationService: EmailAuthorizationService
        fileprivate let sessionTokenService: SessionTokenServiceAPI
        fileprivate let smsService: SMSServiceAPI
        fileprivate let loginService: LoginServiceAPI
        fileprivate let walletFetcher: ManualPairingWalletFetching
        
        /// TODO: Remove from dependencies
        fileprivate let wallet: Wallet
        
        // MARK: - General dependencies
        
        fileprivate let analyticsRecorder: AnalyticsEventRecording
        fileprivate let errorRecorder: ErrorRecording
        
        init(analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
             errorRecorder: ErrorRecording = CrashlyticsRecorder(),
             walletPayloadClient: WalletPayloadClientAPI = WalletPayloadClient(),
             twoFAWalletClient: TwoFAWalletClientAPI = TwoFAWalletClient(),
             guidClient: GuidClientAPI = GuidClient(),
             smsClient: SMSClientAPI = SMSClient(),
             sessionTokenClient: SessionTokenClientAPI = SessionTokenClient(),
             walletRepository: WalletRepositoryAPI = WalletManager.shared.repository,
             wallet: Wallet = WalletManager.shared.wallet,
             walletFetcher: ManualPairingWalletFetching = AuthenticationCoordinator.shared) {
            self.wallet = wallet
            self.walletFetcher = walletFetcher
            self.analyticsRecorder = analyticsRecorder
            self.errorRecorder = errorRecorder
            sessionTokenService = SessionTokenService(
                client: sessionTokenClient,
                repository: walletRepository
            )
            smsService = SMSService(
                client: smsClient,
                repository: walletRepository
            )
            let guidService = GuidService(
                sessionTokenRepository: walletRepository,
                client: guidClient
            )
            emailAuthorizationService = EmailAuthorizationService(guidService: guidService)
            
            let payloadService = WalletPayloadService(
                client: walletPayloadClient,
                repository: walletRepository
            )
            
            let twoFAPayloadService = TwoFAWalletService(
                client: twoFAWalletClient,
                repository: walletRepository
            )
            loginService = LoginService(
                payloadService: payloadService,
                twoFAPayloadService: twoFAPayloadService,
                walletRepository: walletRepository
            )
        }
    }
}
