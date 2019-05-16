//
//  EthereumWalletService.swift
//  EthereumKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

enum EthereumWalletServiceError: Error {
    case unknown
    case waitingOnPendingTransaction
}

public protocol EthereumWalletServiceAPI {
    func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished>
}

public final class EthereumWalletService: EthereumWalletServiceAPI {
    
    // TODOs:
    // * Support for 2nd PW: https://blockchain.atlassian.net/browse/IOS-2193
    // * Support for legacy wallets?
    
    public typealias Bridge = EthereumWalletBridgeAPI
    
    private var fetchBalance: Single<CryptoValue> {
        return bridge.fetchBalance
    }
    
    private var loadKeyPair: Single<EthereumKeyPair> {
        return walletAccountRepository.keyPair.asObservable().asSingle()
    }
    
    private let bridge: Bridge
    private let ethereumAPIClient: EthereumAPIClientAPI
    private let feeService: EthereumFeeServiceAPI
    private let walletAccountRepository: EthereumWalletAccountRepositoryAPI
    private let transactionCreationService: EthereumTransactionCreationService
    
    public init(with bridge: Bridge,
                ethereumAPIClient: EthereumAPIClientAPI,
                feeService: EthereumFeeServiceAPI,
                walletAccountRepository: EthereumWalletAccountRepositoryAPI,
                transactionCreationService: EthereumTransactionCreationService) {
        self.bridge = bridge
        self.ethereumAPIClient = ethereumAPIClient
        self.feeService = feeService
        self.walletAccountRepository = walletAccountRepository
        self.transactionCreationService = transactionCreationService
    }
    
    public func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished> {
        return bridge.isWaitingOnEtherTransaction
            .flatMap { isWaiting -> Single<Void> in
                guard !isWaiting else {
                    return Single.error(EthereumWalletServiceError.waitingOnPendingTransaction)
                }
                return Single.just(())
            }
            .flatMap(weak: self) { (self, _) -> Single<EthereumKeyPair> in
                self.loadKeyPair
            }
            .flatMap(weak: self) { (self, keyPair) -> Single<EthereumTransactionPublished> in
                self.transactionCreationService.send(
                    transaction: transaction,
                    keyPair: keyPair
                )
            }
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                self.record(transaction: transaction)
            }
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                return self.fetchBalance.map { _ -> EthereumTransactionPublished in
                    transaction
                }
            }
    }
    
    private func record(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        print("transaction: \(transaction)")
        print("transaction.web3swiftTransaction: \(transaction.web3swiftTransaction)")
        return bridge.recordLast(transaction: transaction)
    }
}
