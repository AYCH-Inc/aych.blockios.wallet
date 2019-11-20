//
//  FiatCryptoPair.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A transferred value in crypto and fiat
public struct FiatCryptoPair: Equatable {
    public let fiat: FiatValue
    public let crypto: CryptoValue
    
    /// Returns a readable format of Self
    public var readableFormat: String {
        let readableFiat = fiat.toDisplayString(includeSymbol: true)
        let readableCrypto = crypto.toDisplayString(includeSymbol: true)
        return "\(readableCrypto) (\(readableFiat))"
    }
    
    /// Returns `true` if the value is 0
    public var isZero: Bool {
        return fiat.isZero || crypto.isZero
    }
    
    public init(crypto: CryptoValue, fiat: FiatValue) {
        self.crypto = crypto
        self.fiat = fiat
    }
    
    public init(crypto: CryptoValue, exchangeRate: FiatValue) {
        self.crypto = crypto
        fiat = crypto.convertToFiatValue(exchangeRate: exchangeRate)
    }
    
    public init(fiat: FiatValue, priceInFiat: FiatValue, cryptoCurrency: CryptoCurrency) {
        self.fiat = fiat
        crypto = fiat.convertToCryptoValue(exchangeRate: priceInFiat, cryptoCurrency: cryptoCurrency)
    }
    
    public static func +(lhs: FiatCryptoPair, rhs: FiatCryptoPair) throws -> FiatCryptoPair {
        let crypto = try lhs.crypto + rhs.crypto
        let fiat = try lhs.fiat + rhs.fiat
        return FiatCryptoPair(crypto: crypto, fiat: fiat)
    }
    
    public static func -(lhs: FiatCryptoPair, rhs: FiatCryptoPair) throws -> FiatCryptoPair {
        let crypto = try lhs.crypto - rhs.crypto
        let fiat = try lhs.fiat - rhs.fiat
        return FiatCryptoPair(crypto: crypto, fiat: fiat)
    }
    
    public static func zero(of cryptoCurrency: CryptoCurrency, fiatCurrencyCode: String) -> FiatCryptoPair {
        let crypto = CryptoValue.zero(assetType: cryptoCurrency)
        let fiat = FiatValue.zero(currencyCode: fiatCurrencyCode)
        return FiatCryptoPair(crypto: crypto, fiat: fiat)
    }
    
    /// Calculates the value before percentage increase / decrease
    public func value(before percentageChange: Double) throws -> FiatCryptoPair {
        return FiatCryptoPair(
            crypto: try crypto.value(before: percentageChange),
            fiat: fiat.value(before: percentageChange)
        )
    }
}
