//
//  AirdropRegistrationResponse.swift
//  PlatformKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The response returned when registering a `publicKey`
/// for a soon to be received Airdropped asset.
public struct AirdropRegistrationResponse: Codable {
    public let message: String
}
