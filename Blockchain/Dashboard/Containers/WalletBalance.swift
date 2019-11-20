//
//  WalletBalance.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// This construct provides access to the wallet balance.
/// Any supported asset balance should be accessible here.
struct WalletBalance {
    
    // MARK: - Properties
        
    /// Returns `FiatCryptoPairCalculationState` for a given `CryptoCurrency`
    subscript(cyptoCurrency: CryptoCurrency) -> FiatCryptoPairCalculationState {
        return statePerCurrency[cyptoCurrency]!
    }
    
    /// Returns all the states
    var all: [FiatCryptoPairCalculationState] {
        return Array(statePerCurrency.values)
    }
    
    /// Must contain a `.calculating` element for that to return `true`
    var isCalculating: Bool {
        return all.contains { $0.isCalculating }
    }
    
    /// Must contain an `.invalid` element for that to return `true`
    var isInvalid: Bool {
        return all.contains { $0.isInvalid }
    }
    
    /// All elements must have a value for that to return `true`
    var isValue: Bool {
        return !all.contains { !$0.isValue }
    }
    
    /// Returns the total fiat calcuation state
    var totalFiat: FiatValueCalculationState {
        guard !isInvalid else {
            return .invalid(.valueCouldNotBeCalculated)
        }
        guard !isCalculating else {
            return .calculating
        }
        do {
            let values = all.map { $0.value!.fiat }
            let total = try values.dropFirst().reduce(values[0], +)
            return .value(total)
        } catch {
            return .invalid(.valueCouldNotBeCalculated)
        }
    }
    
    // MARK: - Private Properties
    
    private var statePerCurrency: [CryptoCurrency: FiatCryptoPairCalculationState] = [:]
    
    // MARK: - Setup
    
    init(statePerCurrency: [CryptoCurrency: FiatCryptoPairCalculationState]) {
        self.statePerCurrency = statePerCurrency
    }
}
