//
//  AuthenticatorType.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumeration for different two-factor authentication types.
/// `rawValue` equals to the actual backend value.
public enum AuthenticatorType: Int, CaseIterable, Codable {
    
    /// Standard authentication - w/o 2FA
    case standard = 0
    
    /// Authentication w/ `yubiKey`
    case yubiKey = 1
    
    /// Authentication by authorizing an email message
    case email = 2
    
    /// UNSUPPORTED
    case yubikeyMtGox = 3
    
    /// GOOGLE Authenticator app
    case google = 4
    
    /// SMS OTP
    case sms = 5
    
    /// Returns `true` if self is a two factor auth type
    public var isTwoFactor: Bool {
        return self != .standard
    }
    
    public var name: String {
        switch self {
        case .google:
            return LocalizationConstants.AuthType.google
        case .yubiKey:
            return LocalizationConstants.AuthType.yubiKey
        case .sms:
            return LocalizationConstants.AuthType.sms
        case .standard:
            return ""
        default: // Other are unsupported
            return ""
        }
    }
}
