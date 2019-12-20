//
//  EthereumHistoricalTransactionService.swift
//  EthereumKit
//
//  Created by Jack on 27/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import BigInt
import ToolKit
import PlatformKit

public final class EthereumHistoricalTransactionService: HistoricalTransactionAPI {
    
    public typealias Bridge = EthereumWalletBridgeAPI
    
    // MARK: - Properties
    
    public var transactions: Single<[EthereumHistoricalTransaction]> { cachedTransactions.value }
    
    // MARK: - Private properties
    
    // TODO: This will eventually come from the websocket
    private var fetchLatestBlock: Single<Int> {
        client.latestBlock.map { $0.number }
    }
    
    private var latestBlock: Single<Int> {
        cachedLatestBlock.value
    }
    
    private var account: Single<EthereumAssetAccount> { cachedAccount.value }
    
    private let cachedAccount: CachedValue<EthereumAssetAccount>
    private let cachedTransactions: CachedValue<[EthereumHistoricalTransaction]>
    private let cachedLatestBlock: CachedValue<Int>
    
    private let bridge: Bridge
    private let client: APIClientAPI

    // MARK: - Init
    
    public init(with bridge: Bridge, client: APIClientAPI) {
        self.bridge = bridge
        self.client = client
        self.cachedAccount = CachedValue<EthereumAssetAccount>(
            refreshInterval: TimeInterval.greatestFiniteMagnitude
        )
        self.cachedTransactions = CachedValue<[EthereumHistoricalTransaction]>()
        self.cachedLatestBlock = CachedValue<Int>()
        
        cachedAccount.setFetch { [weak self] in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.bridge.account
        }
        
        cachedTransactions.setFetch { [weak self] in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchTransactions()
        }
        
        cachedLatestBlock.setFetch { [weak self] in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchLatestBlock
        }
    }
    
    // MARK: - HistoricalTransactionAPI
    
    public func fetchTransactions() -> Single<[EthereumHistoricalTransaction]> {
        return Single.zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<[EthereumHistoricalTransaction]> in
                let (account, latestBlock) = tuple
                return self.client.transactions(for: account.accountAddress)
                    .map { transactions -> [EthereumHistoricalTransaction] in
                        return transactions.map { transactionResponse -> EthereumHistoricalTransaction in
                            return EthereumHistoricalTransaction(
                                response: transactionResponse,
                                accountAddress: account.accountAddress,
                                latestBlock: latestBlock
                            )
                        }
                    }
            }
    }
}



