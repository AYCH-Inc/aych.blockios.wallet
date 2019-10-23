//
//  AirdropRegistrationRequest.swift
//  PlatformKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Used for registering a `publicKey` for an asset that will be Airdropped.
public struct AirdropRegistrationRequest: Codable {
    /// Token derived from a `NabuSessionTokenResponse`
    let authToken: String
    
    /// The `publicKey` for any `CryptoCurrency` that you are registering
    /// for an Airdrop.
    let publicKey: String
    
    /// The `campaignIdentifier` that is tied to the asset.
    let campaignIdentifier: String
    
    /// A new user is a user who has `.none` for `NabuUser.UserState`
    /// and `isCompletingKyc` evaulates to `false`.
    let newUser: Bool
    
    public init(authToken: String, publicKey: String, campaignIdentifier: String, isNewUser: Bool) {
        self.authToken = authToken
        self.publicKey = publicKey
        self.campaignIdentifier = campaignIdentifier
        self.newUser = isNewUser
    }
}
