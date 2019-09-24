//
//  NetworkClient.swift
//  BitcoinKit
//
//  Created by Jack on 08/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI {
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse>
}

final class APIClient: APIClientAPI {
    
    struct Endpoint {
        
        static let base: [String] = [ "btc" ]
        
        static let unspentOutputs: [String] = base + [ "unspent" ]
    }

    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder
    
    // MARK: - Init

    init(communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator,
         config: Network.Config = Network.Dependencies.default.blockchainAPIConfig,
         requestBuilder: RequestBuilder = RequestBuilder(networkConfig: Network.Dependencies.default.blockchainAPIConfig)) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - APIClientAPI
    
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse> {
        let parameters = [
            URLQueryItem(
                name: "active",
                value: addresses.joined(separator: "|")
            )
        ]
        guard let request = requestBuilder.post(
            path: Endpoint.unspentOutputs,
            parameters: parameters,
            recordErrors: true
        ) else {
            return Single.error(APIClientError.unknown)
        }
        return communicator.perform(request: request)
    }
}
