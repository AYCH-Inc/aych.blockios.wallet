//
//  CryptoFeeService.swift
//  PlatformKit
//
//  Created by AlexM on 8/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public final class CryptoFeeService<T: TransactionFee & Decodable>: CryptoFeeServiceAPI {
    public var fees: Single<T> {
        return getFees().do(onError: { error in
            Logger.shared.error(error)
        })
        .catchErrorJustReturn(T.default)
    }
    
    private let apiUrl: String
    private let communicator: NetworkCommunicatorAPI
    
    public init(apiUrl: String = BlockchainAPI.shared.apiUrl,
                communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.apiUrl = apiUrl
        self.communicator = communicator
    }
    
    private func getFees() -> Single<T> {
        guard let baseURL = URL(string: apiUrl) else {
            return .error(PlatformKitError.default)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["mempool", "fees", T.cryptoType.pathComponent],
            queryParameters: nil
        ) else {
            return .error(PlatformKitError.default)
        }
        let request = NetworkRequest(endpoint: endpoint, method: .get)
        return communicator.perform(request: request)
    }
}
