//
//  WalletSettingsRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct WalletSettingsRequest: Codable {

    struct Formats {
        static let plain = "plain"
    }

    let method: String
    let guid: String
    let sharedKey: String
    let apiCode: String
    let payload: String?
    let length: Int?
    let format: String?

    init(
        method: String,
        guid: String,
        sharedKey: String,
        apiCode: String,
        payload: String? = nil,
        length: Int? = nil,
        format: String? = nil
    ) {
        self.method = method
        self.guid = guid
        self.sharedKey = sharedKey
        self.apiCode = apiCode
        self.payload = payload
        self.length = length
        self.format = format
    }

    enum CodingKeys: String, CodingKey {
        case method
        case guid
        case sharedKey
        case apiCode = "api_code"
        case payload
        case length
        case format
    }
}
