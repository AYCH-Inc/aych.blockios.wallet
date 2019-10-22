//
//  AuthenticationTwoFactorType.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumeration for different two-factor authentication types.
public enum AuthenticationTwoFactorType: Int, CaseIterable, Codable {
    case none = 0
    case yubiKey = 1
    case google = 4
    case sms = 5
    
    public var name: String {
        switch self {
        case .google:
            return LocalizationConstants.AuthType.google
        case .yubiKey:
            return LocalizationConstants.AuthType.yubiKey
        case .sms:
            return LocalizationConstants.AuthType.sms
        case .none:
            return ""
        }
    }
}
