//
//  SMSClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public final class SMSClient: SMSClientAPI {
    
    // MARK: - Properties
        
    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: SMSRequestBuilder

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .wallet) {
        self.requestBuilder = SMSRequestBuilder(requestBuilder: dependencies.requestBuilder)
        self.communicator = dependencies.communicator
    }
    
    // MARK: - API
    
    public func requestOTP(sessionToken: String, guid: String) -> Completable {
        let request = requestBuilder.build(sessionToken: sessionToken, guid: guid)
        return communicator
            .perform(request: request, responseType: EmptyNetworkResponse.self)
    }
}

extension SMSClient {
    
    private struct SMSRequestBuilder {
        
        private let pathComponents = [ "wallet" ]
        
        private enum HeaderKey: String {
            case cookie
        }
        
        private enum Query: String {
            case format
            case shouldResendCode = "resend_code"
            case time = "ct"
        }
        
        // MARK: - Builder
        
        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }
        
        // MARK: - API
        
        func build(sessionToken: String, guid: String) -> NetworkRequest {
            let pathComponents = self.pathComponents + [guid]
            let headers = [HeaderKey.cookie.rawValue: "SID=\(sessionToken)"]
            let parameters = [
                URLQueryItem(
                    name: Query.format.rawValue,
                    value: "json"
                ),
                URLQueryItem(
                    name: Query.shouldResendCode.rawValue,
                    value: "true"
                ),
                URLQueryItem(
                    name: Query.time.rawValue,
                    value: String(Int(Date().timeIntervalSince1970 * 1000.0))
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
