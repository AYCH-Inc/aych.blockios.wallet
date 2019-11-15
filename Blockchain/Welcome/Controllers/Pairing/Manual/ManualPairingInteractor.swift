//
//  ManualPairingInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import RxCocoa

/// Interaction object for manual pairing flow
final class ManualPairingInteractor {
        
    // MARK: - Types
    
    enum AuthType {
        /// Standard auth using guid (wallet identifier) and password
        case standard
        
        /// Special auth using guid (wallet identifier), password and one time 2FA string
        case twoFA(String)
    }
    
    /// The state of the interaction layer
    struct Content {
        var walletIdentifier = ""
        var password = ""
    }
    
    // MARK: - Properties
    
    let contentStateRelay = BehaviorRelay<Content>(value: Content())
    private let twoFARelay = PublishRelay<AuthenticationTwoFactorType>()
    
    /// Streams a 2FA if needed
    var twoFA: Observable<AuthenticationTwoFactorType> {
        return twoFARelay.asObservable()
    }
    
    var authenticationAction: Observable<AuthenticationAction> {
        return authenticationActionRelay.asObservable()
    }
    
    var content: Observable<Content> {
        return contentStateRelay.asObservable()
    }
    
    /// Email authorization service
    let emailAuthorizationService: EmailAuthorizationService
        
    // MARK: - Properties
    
    private let reachability: InternentReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecording
    private let errorRecorder: ErrorRecording
    
    private let manualPairingService: ManualPairingServiceAPI
    private let sessionTokenService: SessionTokenServiceAPI
    private let wallet: Wallet
    
    private let authenticationActionRelay = PublishRelay<AuthenticationAction>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(reachability: InternentReachabilityAPI = InternentReachability(),
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         manualPairingService: ManualPairingServiceAPI = AuthenticationCoordinator.shared,
         guidClient: GuidClientAPI = GuidClient(),
         sessionTokenClient: SessionTokenClientAPI = SessionTokenClient(),
         sessionTokenRepository: SessionTokenRepositoryAPI = WalletRepository(),
         wallet: Wallet = WalletManager.shared.wallet) {
        let guidService = GuidService(
            sessionTokenRepository: sessionTokenRepository,
            client: guidClient
        )
        sessionTokenService = SessionTokenService(
            client: sessionTokenClient,
            repository: sessionTokenRepository
        )
        emailAuthorizationService = EmailAuthorizationService(guidService: guidService)
        self.manualPairingService = manualPairingService
        self.errorRecorder = errorRecorder
        self.wallet = wallet
        self.reachability = reachability
        self.analyticsRecorder = analyticsRecorder
                
        manualPairingService.action
            .bind(to: authenticationActionRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - API
    
    /// TODO: Refactor `AuthenticationCoordinator` and move any pairing related
    /// logic into another specialized service
    func pair(using authType: AuthType = .standard) throws {
        guard reachability.canConnect else {
            throw InternentReachability.ErrorType.interentUnreachable
        }
        switch authType {
        case .twoFA(let otp):
            wallet.twoFactorInput = otp.trimmingWhitespaces
        case .standard:
            wallet.twoFactorInput = nil
        }
        analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletManualLogin)
        
        sessionTokenService.setupSessionToken()
            .subscribe(
                onCompleted: { [weak self] in
                    self?.authenticate()
                },
                onError: { [weak self] error in
                    // TODO: Handle errors by presenting alert via presenter
                    self?.errorRecorder.error(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Invokes authentication
    func authenticate() {
        manualPairingService.authenticate(
            with: contentStateRelay.value.walletIdentifier,
            password: contentStateRelay.value.password) { [weak self] twoFA in
                self?.twoFARelay.accept(twoFA)
            }
    }
    
    /// TODO: Move SMS logic to a native specialized service
    /// Requests `Wallet` to resend an SMS (2FA)
    func resendSMS() {
        wallet.resendTwoFactorSMS()
    }
}
