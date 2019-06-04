//
//  CoinifyMetadata.swift
//  Blockchain
//
//  Created by AlexM on 4/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct CoinifyMetadata: Decodable {
    let traderIdentifier: Int
    let offlineToken: String
    
    enum CodingKeys: String, CodingKey {
        case user
        case token = "offline_token"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        traderIdentifier = try values.decode(Int.self, forKey: .user)
        offlineToken = try values.decode(String.self, forKey: .token)
    }
    
    init(identifier: Int, token: String) {
        self.traderIdentifier = identifier
        self.offlineToken = token
    }
}
