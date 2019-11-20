//
//  Wallet+Rx.swift
//  Blockchain
//
//  Created by Daniel Huri on 05/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

/// An extension to `Wallet` which makes wallet fuctionality Rx friendly.
class ReactiveWallet {
    
    enum StateError: Error {
        case walletUnitinialized
    }
    
    enum State {
        case initialized
        case uninitialized
    }
        
    var waitUntilInitialized: Observable<Void> {
        return initializationState
            .asObservable()
            .map { state -> Void in
                if state == .uninitialized {
                    throw StateError.walletUnitinialized
                }
                return ()
            }
            .retry(
                .delayed(maxCount: 200, time: 0.5),
                scheduler: MainScheduler.instance,
                shouldRetry: { error -> Bool in
                    return true
                }
            )
    }
    
    /// A `Single` that streams a boolean element indicating
    /// whether the wallet is initialized
    var initializationState: Single<State> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                if self.wallet.isInitialized() {
                    observer(.success(.initialized))
                } else {
                    observer(.success(.uninitialized))
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    private let wallet: Wallet
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }
}
