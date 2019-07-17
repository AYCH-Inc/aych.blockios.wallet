//
//  PinError.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Represents any error that might occur during the pin flow
enum PinError: Error {
    
    /// Signifies that the selected pin is invalid. See `Pin` for more info about it.
    case invalid
    
    /// Signifies that the selected pin is identical to previous (change flow)
    case identicalToPrevious
        
    /// Signified that the second pin entered on creation/change flow didn't match the selected one
    case pinMismatch(recovery: () -> Void)
    
    /// Signifies that the user has entered an incorrect pin code. Has an associated message with the numbers of retries left.
    case incorrectPin(String)
    
    /// Signifies that the user tried to authenticate with the wrong pin too many times
    case tooManyAttempts
    
    /// Signifies that server is currently under maintenance.
    case serverMaintenance(message: String)
    
    /// Signifies any unexpected error from our backend
    case serverError(String)
    
    /// Biometric authentication failure
    case biometricAuthenticationFailed(String)
    
    /// Signifies that the current operation cannot be completed as there is no internent connection
    case noInternetConnection(recovery: () -> Void)
    
    /// Stands for any custom error
    case custom(String)
    
    // Techincal errors
    case unretainedSelf
    case nullifiedPinKey
    
    // Error in decryption
    case decryptedPasswordWithZeroLength
    
    /// Converts any type of error into a presentable pin error
    static func map(from error: Error) -> PinError {
        if let error = error as? PinError {
            return error
        }
        return .custom(LocalizationConstants.Errors.genericError)
    }
}
