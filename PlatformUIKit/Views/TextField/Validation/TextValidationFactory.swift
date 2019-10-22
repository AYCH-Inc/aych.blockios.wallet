//
//  TextValidationFactory.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A factory for text validators
public final class TextValidationFactory {
        
    public static var newPassword: NewPasswordValidating {
        return NewPasswordTextValidator()
    }
    
    public static var loginPassword: TextValidating {
        return RegexTextValidator(regex: .notEmpty)
    }
    
    public static var email: TextValidating {
        return RegexTextValidator(regex: .email)
    }
    
    public static var walletIdentifier: TextValidating {
        return RegexTextValidator(regex: .walletIdentifier)
    }
    
    public static var alwaysValid: TextValidating {
        return AlwaysValidValidator()
    }
    
    public static func mnemonic(words: Set<String>) -> MnemonicValidating {
        return MnemonicValidator(words: words)
    }
}
