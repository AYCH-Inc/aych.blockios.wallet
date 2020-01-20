//
//  TriageCryptoCurrency.swift
//  PlatformKit
//
//  Created by Daniel Huri on 30/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

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
    
    public var cryptoCurrency: CryptoCurrency? {
        switch self {
        case .supported(let currency):
            return currency
        case .blockstack:
            return nil
        }
    }
    
    public var maxDecimalPlaces: Int {
        switch self {
        case .supported(let currency):
            return currency.maxDecimalPlaces
        case .blockstack:
            return 7
        }
    }
    
    public var maxDisplayableDecimalPlaces: Int {
        switch self {
        case .supported(let currency):
            return currency.maxDecimalPlaces
        case .blockstack:
            return 7
        }
    }
        
    public func displayValue(amount: BigInt, locale: Locale = Locale.current) -> String {
        let divisor = BigInt(10).power(maxDecimalPlaces)
        var majorValue = amount.decimalDivision(divisor: divisor)
        majorValue = majorValue.roundTo(places: maxDecimalPlaces)
        
        let formatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minfractionDigits: 1,
            maxfractionDigits: maxDisplayableDecimalPlaces
        )
        return formatter.string(from: NSDecimalNumber(decimal: majorValue)) ?? "\(majorValue)"
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
