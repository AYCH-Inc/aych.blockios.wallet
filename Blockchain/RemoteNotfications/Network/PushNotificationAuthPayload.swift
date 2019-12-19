//
//  RemoteNotificationRegistrationPayload.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import NetworkKit
import PlatformKit

struct RemoteNotificationTokenQueryParametersBuilder {

    enum BuildError: Error {
        case guidIsEmpty
        case sharedKeyIsEmpty
        case tokenIsEmpty
    }
    
    private enum Keys: String {
        case guid
        case sharedKey
        case token = "payload"
        case tokenLength = "length"
        case apiCode = "api_code"
    }
    
    var parameters: Data? {
        let queryItems = [
            URLQueryItem(name: Keys.guid.rawValue, value: guid),
            URLQueryItem(name: Keys.sharedKey.rawValue, value: sharedKey),
            URLQueryItem(name: Keys.token.rawValue, value: token),
            URLQueryItem(name: Keys.tokenLength.rawValue, value: "\(token.count)"),
            URLQueryItem(name: Keys.apiCode.rawValue, value: BlockchainAPI.Parameters.apiCode)
        ]
        var components = URLComponents()
        components.queryItems = queryItems
        let query = components.query
        return query?.data(using: .utf8)
    }
    
    private let guid: String
    private let sharedKey: String
    private let token: String
    
    init(guid: String, sharedKey: String, token: String) throws {
        guard !guid.isEmpty else { throw BuildError.guidIsEmpty }
        guard !sharedKey.isEmpty else { throw BuildError.sharedKeyIsEmpty }
        guard !token.isEmpty else { throw BuildError.tokenIsEmpty }
        
        self.guid = guid
        self.sharedKey = sharedKey
        self.token = token
    }
}
