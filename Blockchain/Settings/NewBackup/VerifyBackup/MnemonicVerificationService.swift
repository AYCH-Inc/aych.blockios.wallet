//
//  MnemonicVerificationService.swift
//  Blockchain
//
//  Created by AlexM on 1/21/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

final class MnemonicVerificationService: MnemonicVerificationAPI {
    
    private let wallet: Wallet
    private let jsScheduler = MainScheduler.instance
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }
    
    // MARK: - MnemonicVerificationAPI
    
    var isVerified: Observable<Bool> {
        return Observable.just(wallet.isRecoveryPhraseVerified())
    }
    
    func verifyMnemonicAndSync() -> Completable {
        perform { [weak self] in
            guard let self = self else { return }
            self.wallet.markRecoveryPhraseVerified()
        }
    }
    
    // MARK: - Accessors
    
    private func perform(_ operation: @escaping () -> Void) -> Completable {
        return Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
}
