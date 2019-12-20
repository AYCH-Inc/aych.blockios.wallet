//
//  SessionTokenClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

/// A session token client implementation
public final class SessionTokenClient: SessionTokenClientAPI {
    
    // MARK: - Types
    
    public enum FetchError: Error {
        case missingToken
    }
    
    private struct Response: Decodable {
        let token: String?
    }
    
    // MARK: - Properties

    /// Requests a session token for the wallet, if not available already
    public var token: Single<String> {
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            contentType: .json
        )
        return communicator
            .perform(request: request, responseType: Response.self)
            .map { $0.token }
            .map { token -> String in
                guard let token = token else { throw FetchError.missingToken }
                return token
            }
    }
    
    private let url = URL(string: BlockchainAPI.shared.walletSession)!
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Setup
    
    public init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.communicator = communicator
    }
}
