//
//  CreateWalletScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

// TODO: Refactor this when the coordinators are refactored
/// The interaction layer for wallet creation
final class CreateWalletScreenInteractor: NSObject {
    
    // MARK: - Exposed Properties
    
    let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())
    var content: Observable<WalletRegistrationContent> {
        return contentStateRelay.asObservable()
    }
    
    /// Any error related to the interaction should be reflected to the presenter
    /// Since the JS is async and callbacks oriented, we
    /// want to use a relay to let the presentation layer
    /// know about errors
    var error: Observable<String> {
        return errorRelay.asObservable()
    }
    
    // MARK: - Injected
    
    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecording
    private let wallet: Wallet
    private let walletManager: WalletManager
    
    private let errorRelay = PublishRelay<String>()
    
    // MARK: - Setup
    
    init(reachability: InternetReachabilityAPI = InternetReachability(),
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         authenticationCoordinator: AuthenticationCoordinator = .shared,
         walletManager: WalletManager = .shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager
        self.wallet = wallet
        authenticationCoordinator.temporaryAuthHandler = authenticationCoordinator.authenticationHandler
        super.init()
    }
}

// MARK: - RegisterWalletScreenInteracting

extension CreateWalletScreenInteractor: RegisterWalletScreenInteracting {
    func execute() throws {
        guard reachability.canConnect else {
            throw InternetReachability.ErrorType.internetUnreachable
        }
        
        analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletCreation)
        
        // Get callback when wallet is done loading
        // Continue in walletJSReady callback
        wallet.delegate = self
        wallet.loadJS()
    }
}

// MARK: - WalletDelegate (Should be refactored)

extension CreateWalletScreenInteractor: WalletDelegate {
    func walletJSReady() {
        wallet.newAccount(contentStateRelay.value.password, email: contentStateRelay.value.email)
    }
    
    func didCreateNewAccount(_ guid: String!, sharedKey: String!, password: String!) {
        wallet.delegate = walletManager

        /// Reset wallet + `JSContext`
        walletManager.forgetWallet()

        // Load the newly created wallet
        wallet.load(withGuid: guid, sharedKey: sharedKey, password: password)

        /// Mark the wallet as new
        wallet.isNew = true
        
        // TODO: Remove this?
        BuySellCoordinator.shared.buyBitcoinViewController?.isNew = true
        BlockchainSettings.App.shared.hasEndedFirstSession = false
    }
    
    func errorCreatingNewAccount(_ message: String!) {
        errorRelay.accept(message ?? "")
    }
}
