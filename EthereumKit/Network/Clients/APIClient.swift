//
//  APIClient.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import BigInt
import PlatformKit

enum EthereumAPIClientError: Error {
    case unknown
}

public protocol APIClientAPI {
    
    var latestBlock: Single<LatestBlockResponse> { get }
    
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse>
    func account(for address: String) -> Single<EthereumAccountResponse>
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]>
    func balance(from address: String) -> Single<CryptoValue>
}

public final class APIClient: APIClientAPI {
    
    private struct Endpoint {
        
        static let base: [String] = [ "eth" ]
        
        static let pushTx: [String] = base + [ "pushtx" ]
        
        static let latestBlock: [String] = base + [ "latestblock" ]
        
        static func balance(for address: String) -> [String] {
            return base + [ "account", address, "balance" ]
        }
        
        static func account(for address: String) -> [String] {
            return base + [ "account", address ]
        }
    }
    
    public static let shared = APIClient(
        communicator: NetworkCommunicator.shared,
        config: Network.Dependencies.default.blockchainAPIConfig
    )
    
    public var latestBlock: Single<LatestBlockResponse> {
        let path = Endpoint.latestBlock
        guard let request = requestBuilder.get(path: path) else {
            return Single.error(EthereumAPIClientError.unknown)
        }
        return communicator.perform(request: request)
    }
    
    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder
    
    // MARK: - Init
    
    init(communicator: NetworkCommunicatorAPI,
         config: Network.Config = Network.Dependencies.default.blockchainAPIConfig,
         requestBuilder: RequestBuilder = RequestBuilder(networkConfig: Network.Dependencies.default.blockchainAPIConfig)) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - EthereumAPIClientAPI
    
    public func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse> {
        let pushTxRequest = PushTxRequest(
            rawTx: transaction.rawTx,
            api_code: config.apiCode
        )
        let data = try? JSONEncoder().encode(pushTxRequest)
        guard let request = requestBuilder.post(
            path: Endpoint.pushTx,
            body: data,
            recordErrors: true
        ) else {
            return Single.error(EthereumAPIClientError.unknown)
        }
        return communicator.perform(request: request)
    }
    
    public func account(for address: String) -> Single<EthereumAccountResponse> {
        let path = Endpoint.account(for: address)
        guard let request = requestBuilder.get(path: path) else {
            return Single.error(EthereumAPIClientError.unknown)
        }
        return communicator.perform(
                request: request,
                responseType: [String: EthereumAccountResponse].self
            )
            .map { accountResponse -> EthereumAccountResponse in
                guard let account = accountResponse[address] else {
                    throw EthereumAPIClientError.unknown
                }
                return account
            }
    }
    
    public func transactions(for address: String) -> Single<[EthereumHistoricalTransactionResponse]> {
        return account(for: address).map { $0.txns }
    }
    
    public func balance(from address: String) -> Single<CryptoValue> {
        let path = Endpoint.balance(for: address)
        guard let request = requestBuilder.get(path: path) else {
            return Single.error(EthereumAPIClientError.unknown)
        }
        return communicator.perform(request: request)
            .flatMap { (payload: [String: BalanceDetailsResponse]) -> Single<CryptoValue> in
                Single.just(payload[address]?.cryptoValue ?? CryptoValue.etherZero)
            }
    }
}
