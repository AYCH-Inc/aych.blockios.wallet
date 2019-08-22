//
//  TransferDestinationAccountState.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum TransferDestinationAccountState: Equatable {
    
    /// The state error of the account/address
    enum StateError: Error {
        
        /// The account is empty
        case empty
        
        /// The format of the address is incorrect
        case format
        
        /// Fetch error - relevant if the account is being fetch from remote
        case fetch
    }
    
    /// Empty - signifies the account couldn't be fetched / read
    case invalid(StateError)
    
    /// A valid value
    case valid(address: String)
    
    /// Returns `true` for a valid account
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    /// Returns the address value associated with a valid account
    var addressValue: String? {
        switch self {
        case .valid(address: let value):
            return value
        case .invalid:
            return nil
        }
    }
}
