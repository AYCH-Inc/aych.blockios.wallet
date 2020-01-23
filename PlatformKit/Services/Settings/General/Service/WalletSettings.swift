//
//  WalletSettings.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct WalletSettings {
    
    public let countryCode: String
    public let language: String
    public let fiatCurrency: String
    public let email: String
    public let isSMSVerified: Bool
    public let isEmailNotificationsEnabled: Bool
    public let isEmailVerified: Bool
    public let authenticator: AuthenticatorType
    
    init(response: SettingsResponse) {
        countryCode = response.countryCode
        language = response.language
        fiatCurrency = response.currency
        email = response.email
        isSMSVerified = response.smsVerified
        isEmailVerified = response.emailVerified
        isEmailNotificationsEnabled = response.emailNotificationsEnabled
        authenticator = AuthenticatorType(rawValue: response.authenticator) ?? .standard
    }
}
