//
//  EthereumPlatformService.swift
//  EthereumKit
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import web3swift
import BigInt
import PlatformKit

public struct EthereumPushTxResponse: Decodable, Equatable {
    public let txHash: String
    
    public init(txHash: String) {
        self.txHash = txHash
    }
}

public protocol EthereumAPIClientAPI {
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse>
}

public protocol EthereumFeeServiceAPI {
    var fees: Single<EthereumTransactionFee> { get }
}

public enum EthereumTransactionCreationServiceError: Error {
    case transactionHashingError
    case nullReferenceError
}

public protocol EthereumTransactionCreationServiceAPI {
    func send(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished>
}

public final class EthereumTransactionCreationService: EthereumTransactionCreationServiceAPI {
    
    public typealias Bridge = EthereumWalletBridgeAPI
    
    private let bridge: Bridge
    private let ethereumAPIClient: EthereumAPIClientAPI
    private let feeService: EthereumFeeServiceAPI
    private let transactionBuilder: EthereumTransactionBuilderAPI
    private let transactionSigner: EthereumTransactionSignerAPI
    private let transactionEncoder: EthereumTransactionEncoderAPI
    
    public init(
        with bridge: Bridge,
        ethereumAPIClient: EthereumAPIClientAPI,
        feeService: EthereumFeeServiceAPI,
        transactionBuilder: EthereumTransactionBuilderAPI = EthereumTransactionBuilder.shared,
        transactionSigner: EthereumTransactionSignerAPI = EthereumTransactionSigner.shared,
        transactionEncoder: EthereumTransactionEncoderAPI = EthereumTransactionEncoder.shared) {
        self.bridge = bridge
        self.ethereumAPIClient = ethereumAPIClient
        self.feeService = feeService
        self.transactionBuilder = transactionBuilder
        self.transactionSigner = transactionSigner
        self.transactionEncoder = transactionEncoder
    }
    
    public func send(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished> {
        return create(transaction: transaction, keyPair: keyPair)
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                assert(transaction.web3swiftTransaction.intrinsicChainID == NetworkId.mainnet.rawValue)
                print("transaction: \(transaction)")
                print("transaction.web3swiftTransaction: \(transaction.web3swiftTransaction)")
                print("Going to publish! \n")
                return self.publish(transaction: transaction)
            }
    }

    private func create(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionFinalised> {
        return Single.zip(feeService.fees, bridge.nonce, bridge.balance)
            .flatMap { [weak self] fee, nonce, balance -> Single<EthereumTransactionCandidateCosted> in
                print("    fee: \(fee)")
                print("  nonce: \(nonce)")
                print("balance: \(balance)")
                guard let self = self else {
                    return Single.error(EthereumTransactionCreationServiceError.nullReferenceError)
                }
                return self.transactionBuilder
                    .build(
                        transaction: transaction,
                        balance: balance,
                        nonce: nonce,
                        gasPrice: BigUInt(fee.regular.amount),
                        gasLimit: BigUInt(fee.gasLimit)
                    )
                    .single
            }
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionCandidateSigned> in
                self.transactionSigner.sign(transaction: transaction, keyPair: keyPair).single
            }
            .flatMap(weak: self) { (self, signedTransaction) -> Single<EthereumTransactionFinalised> in
                self.transactionEncoder.encode(signed: signedTransaction).single
            }
    }
    
    private func publish(transaction: EthereumTransactionFinalised) -> Single<EthereumTransactionPublished> {
        return ethereumAPIClient.push(transaction: transaction)
            .debug()
            .flatMap { response in
                let publishedTransaction = try EthereumTransactionPublished(
                    finalisedTransaction: transaction,
                    responseHash: response.txHash
                )
                return Single.just(publishedTransaction)
            }
    }
}
