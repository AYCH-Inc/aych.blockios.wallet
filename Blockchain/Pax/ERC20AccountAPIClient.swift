//
//  PaxService.swift
//  Blockchain
//
//  Created by Jack on 11/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit
import NetworkKit
import PlatformKit
import EthereumKit
import ERC20Kit

public final class AnyERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {
    public func fetchWalletAccount(ethereumAddress: String) -> Single<ERC20AccountResponse<Token>> {
        guard let baseURL = URL(string: apiUrl) else {
            return .error(NetworkRequest.NetworkError.generic)
        }
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: [ "v2", "eth", "data", "account", ethereumAddress, "token", Token.contractAddress.rawValue, "wallet" ],
            queryParameters: nil
        ) else {
            return .error(TradeExecutionAPIError.generic)
        }
        return communicator.perform(request: NetworkRequest(endpoint: endpoint, method: .get))
            .do(onError: { error in
                Logger.shared.error(error)
            })
    }
    
    private let apiUrl: String
    private let communicator: NetworkCommunicatorAPI
    
    init(apiUrl: String = BlockchainAPI.shared.apiUrl, communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.apiUrl = apiUrl
        self.communicator = communicator
    }
}
