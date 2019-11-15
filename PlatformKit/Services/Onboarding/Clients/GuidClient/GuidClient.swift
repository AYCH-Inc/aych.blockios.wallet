//
//  GuidClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 12/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A network client for `GUID`
public final class GuidClient: GuidClientAPI {
            
    // MARK: - Types

    struct Response: Decodable {
        let guid: String
    }
    
    // MARK: - Properties
        
    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: GuidRequestBuilder
    
    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .wallet) {
        self.requestBuilder = GuidRequestBuilder(requestBuilder: dependencies.requestBuilder)
        self.communicator = dependencies.communicator
    }
    
    /// Fetches the `GUID`
    public func guid(by sessionToken: String) -> Single<String> {
        let request = requestBuilder.build(sessionToken: sessionToken)
        return self.communicator
            .perform(request: request, responseType: Response.self)
            .map { $0.guid }
    }
}

// MARK: - GuidRequestBuilder

extension GuidClient {
    
    private struct GuidRequestBuilder {
        
        private let pathComponents = [ "wallet", "poll-for-session-guid" ]
        
        private enum HeaderKey: String {
            case cookie
        }
        
        private enum Query: String {
            case format
            case resendCode = "resend_code"
        }
        
        // MARK: - Builder
        
        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }
        
        // MARK: - API
        
        func build(sessionToken: String) -> NetworkRequest {
            let headers = [HeaderKey.cookie.rawValue: "SID=\(sessionToken)"]
            let parameters = [
                URLQueryItem(
                    name: Query.format.rawValue,
                    value: "json"
                ),
                URLQueryItem(
                    name: Query.resendCode.rawValue,
                    value: "false"
                )
            ]
            return requestBuilder.get(
                path: pathComponents,
                parameters: parameters,
                headers: headers
            )!
        }
    }
}
