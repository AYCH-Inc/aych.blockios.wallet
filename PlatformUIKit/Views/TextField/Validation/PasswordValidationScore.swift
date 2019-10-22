//
//  PasswordValidationScore.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Interaction level password score
public enum PasswordValidationScore {
    
    /// No score - the weakest
    case none
    
    /// Weak password
    case weak
    
    /// Normal password
    case normal
    
    /// Strong password
    case strong
    
    /// Returns `true` if the password is valid.
    /// As a rule, `.none` is not valid, any higher score is
    var isValid: Bool {
        switch self {
        case .none, .weak:
            return false
        case .normal, .strong:
            return true
        }
    }
    
    init(zxcvbnScore: Int32, password: String) {
        guard !password.isEmpty else {
            self = .none
            return
        }
        switch zxcvbnScore {
        case 0, 1:
            self = .weak
        case 2, 3:
            self = .normal
        case 4:
            self = .strong
        default: // unexpected score
            self = .none
        }
    }
}
