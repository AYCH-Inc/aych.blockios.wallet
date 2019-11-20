//
//  SparklineCalculationState.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

/// Sparkline calculation state
public enum SparklineCalculationState {
    
    public enum CalculationError: Error {
        case valueCouldNotBeCalculated
        case empty
    }
    
    /// An array of `Decimal` values that can be mapped along the `Sparkline`
    case value([Decimal])
    
    /// The `Sparkline` should show its calculating state
    case calculating
    
    /// An error was returned when fetching data for populating the `Sparkline`
    case invalid(CalculationError)
    
    /// Returns the value when available
    var value: [Decimal]? {
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
