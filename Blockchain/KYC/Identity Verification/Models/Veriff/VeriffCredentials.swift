//
//  VeriffCredentials.swift
//  Blockchain
//
//  Created by Alex McGregor on 1/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model describing credentials for interacting with the Veriff API
struct VeriffCredentials: Codable {
    let applicantId: String
    let key: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case applicantId
        case key = "token"
        case data
        case url
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let nested = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        applicantId = try values.decode(String.self, forKey: .applicantId)
        key = try values.decode(String.self, forKey: .key)
        url = try nested.decode(String.self, forKey: .url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nested = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        try container.encode(applicantId, forKey: .applicantId)
        try container.encode(key, forKey: .key)
        try nested.encode(url, forKey: .url)
    }
}
