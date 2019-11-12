//
//  LocalizationConstants+TextField.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct LocalizationConstants {
    struct TextField {
        struct Placeholder {
            static let email = NSLocalizedString(
                "Your email",
                comment: "Placeholder for email text field"
            )
            static let password = NSLocalizedString(
                "Password",
                comment: "Placeholder for password text field"
            )
            static let confirmPassword = NSLocalizedString(
                "Confirm password",
                comment: "Placeholder for confirm password text field"
            )
            static let recoveryPhrase = NSLocalizedString(
                "Recovery passphrase",
                comment: "Placeholder for recovery passphrase text field"
            )
            static let walletIdentifier = NSLocalizedString(
                "Wallet Identifier",
                comment: "Placeholder for wallet identifier text field"
            )
        }
        
        struct PasswordScore {
            static let weak = NSLocalizedString(
                "Weak",
                comment: "Label for a Weak password score in password text field"
            )
            static let normal = NSLocalizedString(
                "Medium",
                comment: "Label for a Normal password score in password text field"
            )
            static let strong = NSLocalizedString(
                "Strong",
                comment: "Label for a Strong password score in password text field"
            )
        }
        
        struct Gesture {
            static let passwordMismatch = NSLocalizedString(
                "Password do not match",
                comment: "Error label when two passwords do not match"
            )
            static let invalidEmail = NSLocalizedString(
                "Email address is not valid",
                comment: "Error label when email address is not valid"
            )
            static let invalidRecoveryPhrase = NSLocalizedString(
                "Invalid recovery phrase. Please try again,",
                comment: "Error label when the recovery phrase is incorrect"
            )
            static let walletId = NSLocalizedString(
                "Wallet id is not valid",
                comment: "Error label when wallet id is not valid"
            )
        }
    }
}
