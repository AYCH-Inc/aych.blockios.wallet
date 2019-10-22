//
//  LocalizationConstants.swift
//  PlatformKit
//
//  Created by Daniel Huri on 15/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct LocalizationConstants {
    struct AuthType {
        static let google = NSLocalizedString(
            "Google",
            comment: "2FA alert: google type"
        )
        static let yubiKey = NSLocalizedString(
            "Yubi Key",
            comment: "2FA alert: google type"
        )
        static let sms = NSLocalizedString(
            "SMS",
            comment: "2FA alert: sms type"
        )
    }
}
