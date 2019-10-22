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
    
    var content: Observable<Content> {
        return contentStateRelay.asObservable()
    }
        
    // MARK: - Properties
    
    private let reachability: InternentReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecording
    private let manualPairingService: ManualPairingServiceAPI
    private let wallet: Wallet
    
    // MARK: - Setup
    
    init(reachability: InternentReachabilityAPI = InternentReachability(),
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         manualPairingService: ManualPairingServiceAPI = AuthenticationCoordinator.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.reachability = reachability
        self.manualPairingService = manualPairingService
        self.analyticsRecorder = analyticsRecorder
        self.wallet = wallet
        wallet.loadLogin()
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
        manualPairingService.authenticate(
            with: contentStateRelay.value.walletIdentifier,
            password: contentStateRelay.value.password) { [weak self] twoFA in
                self?.twoFARelay.accept(twoFA)
            }
    }
    
    func resendSMS() {
        wallet.resendTwoFactorSMS()
    }
}
