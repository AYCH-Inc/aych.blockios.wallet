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
import NetworkKit
import PlatformKit

public protocol APIClientProtocol: class {
    
    var latestBlock: Single<LatestBlockResponse> { get }
    
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse>
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]>
    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse>
}

public final class APIClient: APIClientProtocol {
    
    // MARK: - Types
    
    /// Potential errors
    public enum ClientError: Error {
        
        /// Error building the request
        case buildingRequest
        
        /// Balance is missing for address
        case missingBalanceResponseForAddress
        
        /// Account is missing for
        case missingAccountResponseForAddress
    }
    
    /// Privately used endpoint data
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
    
    // MARK: - Public Properties
    
    /// Streams the latest block
    public var latestBlock: Single<LatestBlockResponse> {
        let path = Endpoint.latestBlock
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(request: request)
    }
    
    // MARK: - Private Properties
    
    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder
    
    // MARK: - Setup
    
    public init(communicator: NetworkCommunicatorAPI, config: Network.Config) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = RequestBuilder(networkConfig: config)
    }
    
    public init(dependencies: Network.Dependencies = .default) {
        self.communicator = dependencies.communicator
        self.config = dependencies.blockchainAPIConfig
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    /// Pushes a transaction
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
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(request: request)
    }
    
    /// Fetches transactions for an address - returns an array of transactions
    public func transactions(for address: String) -> Single<[EthereumHistoricalTransactionResponse]> {
        return account(for: address).map { $0.txns }
    }
    
    /// Fetches the balance for an address
    public func balanceDetails(from address: String) -> Single<BalanceDetailsResponse> {
        let path = Endpoint.balance(for: address)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(request: request)
            .map { (payload: [String: BalanceDetailsResponse]) -> BalanceDetailsResponse in
                guard let details = payload[address] else {
                    throw ClientError.missingBalanceResponseForAddress
                }
                return details
            }
    }
    
    private func account(for address: String) -> Single<EthereumAccountResponse> {
        let path = Endpoint.account(for: address)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(
                request: request,
                responseType: [String: EthereumAccountResponse].self
            )
            .map { accountResponse -> EthereumAccountResponse in
                guard let account = accountResponse[address] else {
                    throw ClientError.missingAccountResponseForAddress
                }
                return account
            }
    }
    
}
