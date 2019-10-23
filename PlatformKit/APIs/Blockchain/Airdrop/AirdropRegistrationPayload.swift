//
//  AirdropRegistrationPayload.swift
//  PlatformKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// An internal model used when registering a `publicKey` for an asset
/// that will be Airdropped
struct AirdropRegistrationPayload: Codable {
    let data: [String: String]
    let newUser: Bool
    
    init(publicKey: String, isNewUser: Bool) {
        self.data = [AirdropRegistrationPayload.campaignKey: publicKey]
        self.newUser = isNewUser
    }
}

extension AirdropRegistrationPayload {
    static let campaignKey: String = "x-campaign-address"
}
