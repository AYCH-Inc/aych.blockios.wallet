//
//  SettingsResponse.swift
//  PlatformKit
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// This model contains wallet-specific settings (e.g. the user's preferred language,
/// currency symbol, 2-factor authentication type, etc.)
public struct SettingsResponse {
    let language: String
    let currency: String
    let email: String
    let guid: String
    let emailNotificationsEnabled: Bool
    let smsVerified: Bool
    let emailVerified: Bool
    let authenticator: Int
    let countryCode: String
    let invited: [String: Bool]
}

extension SettingsResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case language
        case currency
        case email
        case guid
        case smsVerified = "sms_verified"
        case emailVerified = "email_verified"
        case authenticator = "auth_type"
        case countryCode = "country_code"
        case notifications = "notifications_type"
        case invited
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        language = try values.decode(String.self, forKey: .language)
        currency = try values.decode(String.self, forKey: .currency)
        email = try values.decode(String.self, forKey: .email)
        guid = try values.decode(String.self, forKey: .guid)
        smsVerified = try values.decode(Int.self, forKey: .smsVerified) == 1
        emailVerified = try values.decode(Int.self, forKey: .emailVerified) == 1
        authenticator = try values.decode(Int.self, forKey: .authenticator)
        countryCode = try values.decode(String.self, forKey: .countryCode)
        invited = try values.decode([String: Bool].self, forKey: .invited)
        let notifications = try values.decode([Int].self, forKey: .notifications)
        emailNotificationsEnabled = notifications.contains(1)
    }
}
