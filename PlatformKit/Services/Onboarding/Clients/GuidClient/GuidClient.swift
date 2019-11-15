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
    
    public enum FetchError: Error {
        case missingSessionToken
    }
    
    struct Response: Decodable {
        let guid: String
    }
    
    // MARK: - Properties
    
    /// Fetches the `GUID`
    public var guid: Single<String> {
        guard let token = sessionTokenRepository.sessionToken else {
            return .error(FetchError.missingSessionToken)
        }
        let request = NetworkRequest(
            endpoint: requestBuilder.url,
            method: .get,
            headers: requestBuilder.header(with: token),
            contentType: .json
        )
        return self.communicator
            .perform(request: request, responseType: Response.self)
            .map { $0.guid }
    }
    
    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder = RequestBuilder()
    
    // MARK: - Setup
    
    public init(sessionTokenRepository: SessionTokenRepositoryAPI,
         communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.sessionTokenRepository = sessionTokenRepository
        self.communicator = communicator
    }
}

// MARK: - RequestBuilder

extension GuidClient {
    
    private struct RequestBuilder {
        
        private enum HeaderKey: String {
            case cookie
        }
        
        private enum Query: String {
            case format
            case apiCode = "api_code"
            case resendCode = "resend_code"
        }
        
        // MARK: - Builders

        /// Returns the full url
        var url: URL {
            let query = [
                Query.format: "json",
                Query.apiCode: BlockchainAPI.Parameters.apiCode,
                Query.resendCode: "false"
                ].reduce("?") { (result, element) -> String in
                    return result + "\(element.key)=\(element.value)"
            }
            return URL(string: "\(BlockchainAPI.shared.sessionGuid)\(query)")!
        }
                
        /// Returns the header
        func header(with token: String) -> [String: String] {
            return [HeaderKey.cookie.rawValue: "SID=\(token)"]
        }
    }
}
