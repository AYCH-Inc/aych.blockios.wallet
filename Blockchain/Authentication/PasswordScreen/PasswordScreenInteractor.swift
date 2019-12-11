//
//  PasswordScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

protocol PasswordScreenInteracting: class {
    var type: PasswordScreenType { get }
    var passwordRelay: BehaviorRelay<String> { get }
    var isValid: Bool { get }
}

final class PasswordScreenInteractor: PasswordScreenInteracting {
    
    // MARK: - Exposed Properties
        
    let passwordRelay = BehaviorRelay<String>(value: "")
    let type: PasswordScreenType

    // MARK: - Injected
    
    private let wallet: Wallet
    
    // MARK: - Setup
    
    init(type: PasswordScreenType,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.type = type
        self.wallet = wallet
    }
    
    // MARK: - API
    
    var isValid: Bool {
        switch type {
        case .importPrivateKey:
            return true
        case .actionRequiresPassword, .etherService:
            return wallet.validateSecondPassword(passwordRelay.value)
        }
    }
}
