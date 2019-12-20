//
//  RecoverWalletScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit

final class RecoverWalletScreenInteractor {
    
    // MARK: - Exposed Properties
    
    let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())
    var content: Observable<WalletRegistrationContent> {
        return contentStateRelay.asObservable()
    }
    
    /// Reflects errors received from the JS layer
    var error: Observable<String> {
        return errorRelay.asObservable()
    }
    
    // MARK: - Injected
    
    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecording
    private let wallet: Wallet
    private let walletManager: WalletManager
    
    /// A passphase for recovery
    private let passphrase: String
    
    // MARK: - Accessors
    
    private let errorRelay = PublishRelay<String>()
    
    // MARK: - Setup
    
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         passphrase: String,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         reachability: InternetReachabilityAPI = InternetReachability(),
         walletManager: WalletManager = .shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.passphrase = passphrase
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager
        self.wallet = wallet
        authenticationCoordinator.temporaryAuthHandler = authenticationCoordinator.authenticationHandler
    }
}

// MARK: - RegisterWalletScreenInteracting

extension RecoverWalletScreenInteractor: RegisterWalletScreenInteracting {
    func execute() throws {
        guard reachability.canConnect else {
            throw InternetReachability.ErrorType.internetUnreachable
        }

        wallet.loadJS()
        
        wallet.recover(
            withEmail: contentStateRelay.value.email,
            password: contentStateRelay.value.password,
            passphrase: passphrase)

        wallet.delegate = WalletManager.shared
    }
}
