//
//  NabuSessionTokenResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

/// Model encapsulating the network response from the `/auth` endpoint.
public struct NabuSessionTokenResponse {
    public let identifier: String
    public let userId: String
    public let token: String
    public let isActive: Bool
    public let expiresAt: Date?
    
    public init(identifier: String,
        userId: String,
        token: String,
        isActive: Bool,
        expiresAt: Date?) {
        self.identifier = identifier
        self.userId = userId
        self.token = token
        self.isActive = isActive
        self.expiresAt = expiresAt
    }
}

extension NabuSessionTokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userId = "userId"
        case token = "token"
        case isActive = "isActive"
        case expiresAt = "expiresAt"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        userId = try values.decode(String.self, forKey: .userId)
        token = try values.decode(String.self, forKey: .token)
        isActive = try values.decode(Bool.self, forKey: .isActive)
        let expiresAtString = try values.decode(String.self, forKey: .expiresAt)
        expiresAt = DateFormatter.sessionDateFormat.date(from: expiresAtString)
    }
}
