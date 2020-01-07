//
//  TriageCryptoCurrency.swift
//  PlatformKit
//
//  Created by Daniel Huri on 30/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// This pattern is used to temporarily present new crypto-currencies in features like airdrops.
/// When the currency is fully supported, the case should be removed from `TriageCryptoCurrency`
/// and put in `CryptoCurrency` in its stead.
public enum TriageCryptoCurrency: Equatable {
    enum CryptoError: Error {
        case cryptoCurrencyAdditionRequired
    }
    
    case blockstack
    case supported(CryptoCurrency)
    
    public var symbol: String {
        switch self {
        case .blockstack:
            return "STX"
        case .supported(let currency):
            return currency.symbol
        }
    }
}

extension TriageCryptoCurrency {
    public init(cryptoCurrency: CryptoCurrency) {
        self = .supported(cryptoCurrency)
    }
    
    public init(symbol: String) throws {
        if let supportedCurrency = CryptoCurrency(rawValue: symbol) {
            self = .supported(supportedCurrency)
        } else {
            switch symbol {
            case TriageCryptoCurrency.blockstack.symbol:
                self = .blockstack
            default:
                throw CryptoError.cryptoCurrencyAdditionRequired
            }
        }
    }
}
