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

public protocol EthereumFeeServiceAPI {
    var fees: Single<EthereumTransactionFee> { get }
}

public enum EthereumTransactionCreationServiceError: Error {
    case transactionHashingError
    case nullReferenceError
}

public protocol EthereumTransactionSendingServiceAPI {
    func send(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished>
}

public final class EthereumTransactionSendingService: EthereumTransactionSendingServiceAPI {
    
    public typealias Bridge = EthereumWalletBridgeAPI
    
    private let bridge: Bridge
    private let client: APIClientProtocol
    private let feeService: EthereumFeeServiceAPI
    private let transactionBuilder: EthereumTransactionBuilderAPI
    private let transactionSigner: EthereumTransactionSignerAPI
    private let transactionEncoder: EthereumTransactionEncoderAPI
    
    public init(
        with bridge: Bridge,
        client: APIClientProtocol,
        feeService: EthereumFeeServiceAPI,
        transactionBuilder: EthereumTransactionBuilderAPI = EthereumTransactionBuilder.shared,
        transactionSigner: EthereumTransactionSignerAPI = EthereumTransactionSigner.shared,
        transactionEncoder: EthereumTransactionEncoderAPI = EthereumTransactionEncoder.shared) {
        self.bridge = bridge
        self.client = client
        self.feeService = feeService
        self.transactionBuilder = transactionBuilder
        self.transactionSigner = transactionSigner
        self.transactionEncoder = transactionEncoder
    }
    
    public func send(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished> {
        return finalise(transaction: transaction, keyPair: keyPair)
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                assert(transaction.web3swiftTransaction.intrinsicChainID == NetworkId.mainnet.rawValue)
                return self.publish(transaction: transaction)
            }
    }

    private func finalise(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionFinalised> {
        return bridge.nonce
            .flatMap(weak: self) { (self, nonce) -> Single<(EthereumTransactionCandidateCosted, BigUInt)> in
                return self.transactionBuilder.build(transaction: transaction).single
                    .map { tx -> (EthereumTransactionCandidateCosted, BigUInt) in
                        (tx, nonce)
                    }
            }
            .flatMap(weak: self) { (self, value) -> Single<EthereumTransactionCandidateSigned> in
                let (transaction, nonce) = value
                return self.transactionSigner.sign(transaction: transaction, nonce: nonce, keyPair: keyPair).single
            }
            .flatMap(weak: self) { (self, signedTransaction) -> Single<EthereumTransactionFinalised> in
                self.transactionEncoder.encode(signed: signedTransaction).single
            }
    }

    private func publish(transaction: EthereumTransactionFinalised) -> Single<EthereumTransactionPublished> {
        return client.push(transaction: transaction)
            .flatMap { response in
                let publishedTransaction = try EthereumTransactionPublished(
                    finalisedTransaction: transaction,
                    responseHash: response.txHash
                )
                return Single.just(publishedTransaction)
            }
    }
}

