//
//  WalletSettings.swift
//  PlatformKit
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// This model contains wallet-specific settings (e.g. the user's preferred language,
/// currency symbol, 2-factor authentication type, etc.)
public struct WalletSettings: Codable {
    public let language: String
    public let currency: String
    public let email: String
    public let guid: String
    public let smsVerified: Bool
    public let emailVerified: Bool
    public let authenticationTwoFactorType: AuthenticationTwoFactorType
    public let countryCode: String

    // TODO convert this into an object
    // TICKET: IOS-1672
    public let invited: [String: Bool]
    //    "invited": {
    //        "sfoxBuyV4": true,
    //        "sfoxSell": true,
    //        "lockbox": true,
    //        "sfoxBuy": false,
    //        "kyc": true,
    //        "coinify": true,
    //        "coinifySell": true,
    //        "coinifyBuy": true,
    //        "sfox": true,
    //        "coinifyRecurringBuy": true,
    //        "unocoin": true
    //    }

    enum CodingKeys: String, CodingKey {
        case language
        case currency
        case email
        case guid
        case smsVerified = "sms_verified"
        case emailVerified = "email_verified"
        case authenticationTwoFactorType = "auth_type"
        case countryCode = "country_code"
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
        let rawAuthType = try values.decode(Int.self, forKey: .authenticationTwoFactorType)
        authenticationTwoFactorType = AuthenticationTwoFactorType(rawValue: rawAuthType) ?? .none
        countryCode = try values.decode(String.self, forKey: .countryCode)
        invited = try values.decode([String: Bool].self, forKey: .invited)
    }
}
