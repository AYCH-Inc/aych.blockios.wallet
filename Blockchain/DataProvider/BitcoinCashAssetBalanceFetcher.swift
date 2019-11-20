//
//  BitcoinCashAssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift

final class BitcoinCashAssetBalanceFetcher: AccountBalanceFetching {
    
    // MARK: - Exposed Properties
    
    var balance: Single<CryptoValue> {
        return .just(.bitcoinCashFromSatoshis(int: Int(wallet.getBchBalance())))
    }
    
    var balanceObservable: Observable<CryptoValue> {
        return balanceRelay.asObservable()
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let wallet: Wallet
    
    // MARK: - Setup
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.asyncInstance)
            .flatMapLatest(weak: self) { (self, _) in
                return self.balance.asObservable()
            }
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }
}
