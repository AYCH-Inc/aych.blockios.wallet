//
//  MnemonicValidationScore.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/10/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum MnemonicValidationScore: Equatable {
    
    /// There's no score as there is no entry
    case none
    
    /// Valid words have been provided,
    /// but there is not enough to fulfill the complete requirement
    case incomplete
    
    /// One of the provided words is not included in the WordList
    /// `[NSRange]` is the range of the words that are incorrect
    case invalid([NSRange])
    
    /// Valid words have been provided
    /// and there are enough words to complete the mnemonic
    case complete
    
    /// The score is only valid if the mnemonic is complete
    var isValid: Bool {
        switch self {
        case .complete:
            return true
        case .incomplete, .invalid, .none:
            return false
        }
    }
}

public extension MnemonicValidationScore {
    static func ==(lhs: MnemonicValidationScore, rhs: MnemonicValidationScore) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.incomplete, .incomplete),
             (.complete, .complete):
            return true
        case (.invalid(let left), .invalid(let right)):
            return left == right
        default:
            return false
        }
    }
}
