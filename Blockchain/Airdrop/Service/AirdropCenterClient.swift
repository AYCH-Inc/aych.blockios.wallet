//
//  AirdropCenterClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import NetworkKit

protocol AirdropCenterClientAPI: class {
    func campaigns(using sessionToken: String) -> Single<AirdropCampaigns>
}

/// TODO: Move into `PlatformKit` when https://blockchain.atlassian.net/browse/IOS-2724 is merged
final class AirdropCenterClient: AirdropCenterClientAPI {
    
    // MARK: - Properties
    
    private let pathComponents = [ "users", "user-campaigns" ]
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Setup
    
    init(dependencies: Network.Dependencies = .retail) {
        communicator = dependencies.communicator
        requestBuilder = dependencies.requestBuilder
    }
    
    func campaigns(using sessionToken: String) -> Single<AirdropCampaigns> {
        let endpoint = URL.endpoint(
            URL(string: BlockchainAPI.shared.retailCoreUrl)!,
            pathComponents: pathComponents,
            queryParameters: nil
        )!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .get,
            headers: [HttpHeaderField.authorization: sessionToken]
        )
        return communicator.perform(request: request)
    }
}
