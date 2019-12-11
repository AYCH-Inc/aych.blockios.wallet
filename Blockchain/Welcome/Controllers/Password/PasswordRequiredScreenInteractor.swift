//
//  PasswordRequiredScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class PasswordRequiredScreenInteractor {
    
    // MARK: - Types
    
    enum ErrorType: Error {
        case keychain
    }
    
    // MARK: - Properties
    
    /// Streams potential parsing errors
    var error: Observable<ErrorType> {
        return errorRelay.asObservable()
    }
    
    /// Relay that accepts and streams the payload content
    let passwordRelay = BehaviorRelay<String>(value: "")

    private let authenticationService: AuthenticationCoordinator
    private let appSettings: BlockchainSettings.App
    private let walletManager: WalletManager
    private let errorRelay = PublishRelay<ErrorType>()
    
    // MARK: - Setup
    
    init(walletManager: WalletManager = .shared,
         authenticationService: AuthenticationCoordinator = .shared,
         appSettings: BlockchainSettings.App = .shared) {
        self.walletManager = walletManager
        self.authenticationService = authenticationService
        self.appSettings = appSettings
    }
    
    /// Authenticates the wallet
    func authenticate() {
        guard let guid = appSettings.guid, let sharedKey = appSettings.sharedKey else {
            errorRelay.accept(ErrorType.keychain)
            return
        }
        let payload = PasscodePayload(guid: guid, password: passwordRelay.value, sharedKey: sharedKey)
        authenticationService.authenticate(using: payload)
    }
    
    /// Forgets the wallet
    func forget() {
        walletManager.forgetWallet()
        appSettings.clear()
    }
}
