//
//  EthereumAPIClient.swift
//  Blockchain
//
//  Created by Jack on 29/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import BigInt
import PlatformKit
import EthereumKit

struct PushTxRequest: Encodable {
    let rawTx: String
    let api_code: String
}

enum EthereumAPIClientError: Error {
    case unknown
}

class EthereumAPIClient: EthereumAPIClientAPI {
    
    struct NetworkConfig {
        let apiScheme: String
        let apiHost: String
        let apiCode: String

        static let defaultConfig: NetworkConfig = NetworkConfig(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.apiHost,
            apiCode: "1770d5d9-bcea-4d28-ad21-6cbd5be018a8" // TODO: is this the correct value?
        )

        static let pushTxPath: String = "eth/pushtx"
    }
    
    static let shared = EthereumAPIClient(communicator: NetworkCommunicator.shared, networkConfig: NetworkConfig.defaultConfig)
    
    private var defaultComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkConfig.apiScheme
        urlComponents.host = networkConfig.apiHost
        return urlComponents
    }

    private let communicator: NetworkCommunicatorAPI
    private let networkConfig: NetworkConfig
    
    init(communicator: NetworkCommunicatorAPI, networkConfig: NetworkConfig) {
        self.communicator = communicator
        self.networkConfig = networkConfig
    }
    
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumKit.EthereumPushTxResponse> {
        guard let url = buildURL(path: NetworkConfig.pushTxPath) else {
            return Single.error(EthereumAPIClientError.unknown)
        }
        let pushTxRequest = PushTxRequest(
            rawTx: transaction.rawTx,
            api_code: networkConfig.apiCode
        )
        let data = try? JSONEncoder().encode(pushTxRequest)
        let networkRequest = NetworkRequest(endpoint: url, method: .post, body: data)
        return communicator.perform(request: networkRequest)
    }
    
    private func buildURL(path: String, parameters: [URLQueryItem] = []) -> URL? {
        var components = defaultComponents
        components.path = "/" + path
        components.queryItems = parameters
        return components.url
    }
}
