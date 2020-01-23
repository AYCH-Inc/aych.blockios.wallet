//
//  RecoveryPhraseStatusProviding.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

protocol RecoveryPhraseStatusProviding {
    var isRecoveryPhraseVerified: Observable<Bool> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

final class RecoveryPhraseStatusProvider: RecoveryPhraseStatusProviding {
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private let wallet: Wallet
    
    var isRecoveryPhraseVerified: Observable<Bool> {
        return Observable.combineLatest(Observable.just(wallet.isRecoveryPhraseVerified()), fetchTriggerRelay).map { $0.0 }
    }
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }
}
