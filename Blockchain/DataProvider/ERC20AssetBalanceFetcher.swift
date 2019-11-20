//
//  ERC20AssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift
import RxRelay

final class ERC20AssetBalanceFetcher: AccountBalanceFetching {

    // MARK: - Exposed Properties
    
    var balance: Single<CryptoValue> {
        return assetAccountRepository
            .currentAssetAccountDetails(fromCache: true)
            .asObservable()
            .asSingle()
            .map { details -> CryptoValue in
                return details.balance
            }
    }

    var balanceObservable: Observable<CryptoValue> {
        return balanceRelay.asObservable()
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    private let assetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    
    // MARK: - Setup
    
    init(wallet: EthereumWalletBridgeAPI = WalletManager.shared.wallet.ethereum) {
        let service = ERC20AssetAccountDetailsService(
            with: wallet,
            accountClient: AnyERC20AccountAPIClient<PaxToken>()
        )
        assetAccountRepository = ERC20AssetAccountRepository(service: service)
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                return self.balance.asObservable()
            }
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }
}
