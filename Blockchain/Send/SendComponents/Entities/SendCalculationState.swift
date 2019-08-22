//
//  SendCalculationState.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

/// Fee value calculation indicator - *optional free* approach toward precalculated values
enum SendCalculationState {
    
    enum CalculationError: Error {
        case valueCouldNotBeCalculated
        case empty
    }
    
    /// Fee available
    case value(TransferredValue)
    
    /// Fee is being calculated
    case calculating
    
    case invalid(CalculationError)
    
    /// Returns the value when available
    var value: TransferredValue? {
        switch self {
        case .value(let value):
            return value
        case .calculating, .invalid:
            return nil
        }
    }
    
    /// Returns `true` if has a value
    var isValue: Bool {
        switch self {
        case .value:
            return true
        case .calculating, .invalid:
            return false
        }
    }
    
    var isCalculating: Bool {
        switch self {
        case .calculating:
            return true
        case .invalid, .value:
            return false
        }
    }
}
