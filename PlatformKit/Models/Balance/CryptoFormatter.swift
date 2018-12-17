//
//  CryptoFormatter.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates the different precision levels for formatting a `CryptoValue` into a String
///
/// - short: a short precision (e.g. ETH has 18 precision but displayable precision is less)
/// - long: a long precision (i.e. the full precision of the currency)
public enum CryptoPrecision {
    case short
    case long
}

class CryptoFormatterProvider {

    static let shared = CryptoFormatterProvider()

    private var formatterMap = [String: CryptoFormatter]()

    func formatter(locale: Locale, cryptoCurrency: CryptoCurrency) -> CryptoFormatter {
        let mapKey = key(locale: locale, cryptoCurrency: cryptoCurrency)
        guard let matchingFormatter = formatterMap[mapKey] else {
            let formatter = CryptoFormatter(locale: locale, cryptoCurrency: cryptoCurrency)
            formatterMap[mapKey] = formatter
            return formatter
        }
        return matchingFormatter
    }

    private func key(locale: Locale, cryptoCurrency: CryptoCurrency) -> String {
        guard let languageCode = locale.languageCode else {
            return cryptoCurrency.symbol
        }
        return "\(languageCode)_\(cryptoCurrency.symbol)"
    }
}

class CryptoFormatter {
    private let shortFormatter: NumberFormatter
    private let longFormatter: NumberFormatter
    private let cryptoCurrency: CryptoCurrency

    init(locale: Locale, cryptoCurrency: CryptoCurrency) {
        self.shortFormatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minfractionDigits: 1,
            maxfractionDigits: cryptoCurrency.maxDisplayableDecimalPlaces
        )
        self.longFormatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minfractionDigits: 1,
            maxfractionDigits: cryptoCurrency.maxDecimalPlaces
        )
        self.cryptoCurrency = cryptoCurrency
    }

    func format(value: CryptoValue, withPrecision precision: CryptoPrecision = CryptoPrecision.short, includeSymbol: Bool = false) -> String {
        let formatter = (precision == .short) ? shortFormatter : longFormatter
        var formattedString = formatter.string(from: NSDecimalNumber(decimal: value.majorValue)) ?? "\(value.majorValue)"
        if includeSymbol {
            formattedString += " " + value.currencyType.symbol
        }
        return formattedString
    }
}

extension NumberFormatter {
    fileprivate static func cryptoFormatter(locale: Locale, minfractionDigits: Int, maxfractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = minfractionDigits
        formatter.maximumFractionDigits = maxfractionDigits
        formatter.roundingMode = .down
        return formatter
    }
}
