//
//  SendSourceAccountInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

/// Deals with the source account interaction on the send flow.
final class SendSourceAccountInteractor: SendSourceAccountInteracting {
    
    // MARK: - Exposed Properties
    
    /// Returns the *selected* source account to send crypto from
    var account: Observable<SendSourceAccount> {
        return accountRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    /// The source account to send crypto from
    private let accountRelay: BehaviorRelay<SendSourceAccount>
    
    private let provider: SendSourceAccountProviding
    
    // MARK: - Setup
    
    init(provider: SendSourceAccountProviding) {
        self.provider = provider
        accountRelay = BehaviorRelay(value: provider.default)
    }
}
