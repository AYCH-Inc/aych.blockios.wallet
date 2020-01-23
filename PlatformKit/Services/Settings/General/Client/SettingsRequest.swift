//
//  SettingsRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct SettingsRequest: Codable {

    // MARK: - Types
    
    struct Formats {
        static let plain = "plain"
    }
    
    enum CodingKeys: String, CodingKey {
        case method
        case guid
        case sharedKey
        case apiCode = "api_code"
        case payload
        case length
        case format
        case context
    }
    
    // MARK: - Properties

    let method: String
    let guid: String
    let sharedKey: String
    let apiCode: String
    let payload: String?
    let length: String?
    let format: String?
    let context: String?

    // MARK: - Setup
    
    init(
        method: String,
        guid: String,
        sharedKey: String,
        apiCode: String,
        payload: String? = nil,
        length: String? = nil,
        format: String? = nil,
        context: String? = nil
    ) {
        self.method = method
        self.guid = guid
        self.sharedKey = sharedKey
        self.apiCode = apiCode
        self.payload = payload
        self.length = length
        self.format = format
        self.context = context
    }
}
