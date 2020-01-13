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
    
    public var latestTransaction: Single<EthereumHistoricalTransaction?> {
        cachedTransactions.value.map { $0.first }
    }
    
    /// Streams a boolean indicating whether there are transactions in the account
    public var hasTransactions: Single<Bool> {
        transactions.map { !$0.isEmpty }
    }
    
    // MARK: - Private properties
    
    private var latestBlock: Single<Int> {
        cachedLatestBlock.value
    }
    
    private var account: Single<EthereumAssetAccount> { cachedAccount.value }
    
    private let cachedAccount: CachedValue<EthereumAssetAccount>
    private let cachedTransactions: CachedValue<[EthereumHistoricalTransaction]>
    private let cachedLatestBlock: CachedValue<Int>
    
    private let bridge: Bridge
    private let client: APIClientProtocol

    // MARK: - Init
    
    public init(with bridge: Bridge, client: APIClientProtocol) {
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
            return self.fetch()
        }
        
        cachedLatestBlock.setFetch { [weak self] in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchLatestBlock()
        }
    }
    
    // MARK: - HistoricalTransactionAPI
    
    /// Triggers transaction fetch and caches the new transactions
    public func fetchTransactions() -> Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.fetchValue
    }
    
    public func hasTransactionBeenProcessed(transactionHash: String) -> Single<Bool> {
        return transactions
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { $0.contains { $0.transactionHash == transactionHash } }
    }
    
    // MARK: - Privately used accessors
        
    private func fetch() -> Single<[EthereumHistoricalTransaction]> {
        return Single
            .zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<[EthereumHistoricalTransaction]> in
                let (account, latestBlock) = tuple
                return self.client.transactions(for: account.accountAddress)
                    .map(weak: self) { (self, response) -> [EthereumHistoricalTransaction] in
                        return self.transactions(
                            from: account.accountAddress,
                            latestBlock: latestBlock,
                            response: response
                        )
                    }
            }
    }
    
    private func fetchLatestBlock() -> Single<Int> {
        client.latestBlock.map { $0.number }
    }
    
    private func transactions(from address: String,
                              latestBlock: Int,
                              response: [EthereumHistoricalTransactionResponse]) -> [EthereumHistoricalTransaction] {
        return response
            .map { transactionResponse -> EthereumHistoricalTransaction in
                return EthereumHistoricalTransaction(
                    response: transactionResponse,
                    accountAddress: address,
                    latestBlock: latestBlock
                )
            }
            // Sort backwards
            .sorted(by: >)
    }
}
