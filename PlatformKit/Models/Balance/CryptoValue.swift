//
//  CryptoValue.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

public struct ComparisonError: Error {
    let currencyType1: CryptoCurrency
    let currencyType2: CryptoCurrency
}

public struct CryptoValue {
    public let currencyType: CryptoCurrency
    
    /// The amount is the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    public let amount: BigInt
}

// MARK: - Money

extension CryptoValue: Money {
    
    public var currencyCode: String {
        return self.currencyType.symbol
    }
    
    public var isZero: Bool {
        return amount.isZero
    }
    
    public var isPositive: Bool {
        return amount.sign == .plus
    }
    
    /// The symbol for the money (e.g. "BTC", "ETH", etc.)
    public var symbol: String {
        return self.currencyType.symbol
    }
    
    /// The maximum number of decimal places supported by the money
    public var maxDecimalPlaces: Int {
        return self.currencyType.maxDecimalPlaces
    }
    
    /// The maximum number of displayable decimal places.
    public var maxDisplayableDecimalPlaces: Int {
        return self.currencyType.maxDisplayableDecimalPlaces
    }
    
    /// Converts this money to a displayable String in its major format
    ///
    /// - Parameter includeSymbol: whether or not the symbol should be included in the string
    /// - Returns: the displayable String
    public func toDisplayString(includeSymbol: Bool) -> String {
        // TODO redo number formatting
        // TICKET: IOS-1721
        let formatter = NumberFormatter.decimalStyleFormatter(
            withMinfractionDigits: 0,
            maxfractionDigits: currencyType.maxDisplayableDecimalPlaces,
            usesGroupingSeparator: false
        )
        var formattedString = formatter.string(from: NSDecimalNumber(decimal: majorValue)) ?? "\(majorValue)"
        if includeSymbol {
            formattedString += " " + currencyType.symbol
        }
        return formattedString
    }
}

// MARK: - Operators

extension CryptoValue: Hashable, Equatable {
    private static func ensureComparable(value: CryptoValue, other: CryptoValue) throws {
        if value.currencyType != other.currencyType {
            throw ComparisonError(currencyType1: value.currencyType, currencyType2: other.currencyType)
        }
    }
    
    public static func +(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount + rhs.amount)
    }
    
    public static func -(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount - rhs.amount)
    }
    
    public static func *(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount * rhs.amount)
    }
    
    public static func +=(lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs + rhs
    }
    
    public static func -=(lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs - rhs
    }
    
    public static func *= (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs * rhs
    }
}

// MARK: - Shared

public extension CryptoValue {
    /// The major value of the crypto (e.g. BTC, ETH, etc.)
    public var majorValue: Decimal {
        let divisor = BigInt(10).power(currencyType.maxDecimalPlaces)
        let majorValue = amount.decimalDivision(divisor: divisor)
        return majorValue.roundTo(places: currencyType.maxDecimalPlaces)
    }
    
    public static func createFromMajorValue(_ value: Decimal, assetType: CryptoCurrency) -> CryptoValue {
        let doubleValue = Double(truncating: NSDecimalNumber(decimal: value))
        let decimalValue = doubleValue.truncatingRemainder(dividingBy: 1) * pow(10.0, Double(assetType.maxDecimalPlaces))
        let mantissaValue = BigInt(Int(truncating: NSDecimalNumber(decimal: value))) * BigInt(10).power(assetType.maxDecimalPlaces)
        let amount = mantissaValue + BigInt(decimalValue)
        return CryptoValue(currencyType: assetType, amount: amount)
    }
}

// MARK: - Bitcoin

public extension CryptoValue {
    public static func bitcoinFromSatoshis(int satoshis: Int) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoin, amount: BigInt(satoshis))
    }
    
    public static func bitcoinFromSatoshis(long satoshis: CLong) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoin, amount: BigInt(satoshis))
    }
    
    public static func bitcoinFromMajor(int bitcoin: Int) -> CryptoValue {
        return createFromMajorValue(Decimal(bitcoin), assetType: .bitcoin)
    }
    
    public static func bitcoinFromMajor(decimal bitcoin: Decimal) -> CryptoValue {
        return createFromMajorValue(bitcoin, assetType: .bitcoin)
    }
}

// MARK: - Ethereum

public extension CryptoValue {
    public static func etherFromWei(long wei: CLong) -> CryptoValue {
        return CryptoValue(currencyType: .ethereum, amount: BigInt(wei))
    }
    
    public static func etherFromWei(int wei: Int) -> CryptoValue {
        return CryptoValue(currencyType: .ethereum, amount: BigInt(wei))
    }
    
    public static func etherFromMajor(long ether: CLong) -> CryptoValue {
        return createFromMajorValue(Decimal(ether), assetType: .ethereum)
    }
    
    public static func etherFromMajor(decimal ether: Decimal) -> CryptoValue {
        return createFromMajorValue(ether, assetType: .ethereum)
    }
}

// MARK: - Bitcoin Cash

public extension CryptoValue {
    public static func bitcoinCashFromSatoshis(int satoshis: Int) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoinCash, amount: BigInt(satoshis))
    }
    
    public static func bitcoinCashFromSatoshis(long satoshis: CLong) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoinCash, amount: BigInt(satoshis))
    }
    
    public static func bitcoinCashFromMajor(int bitcoinCash: Int) -> CryptoValue {
        return createFromMajorValue(Decimal(bitcoinCash), assetType: .bitcoinCash)
    }
    
    public static func bitcoinCashFromMajor(decimal bitcoinCash: Decimal) -> CryptoValue {
        return createFromMajorValue(bitcoinCash, assetType: .bitcoinCash)
    }
}

// MARK: - Stellar

public extension CryptoValue {
    public static func lumensFromMajor(int lumens: Int) -> CryptoValue {
        return createFromMajorValue(Decimal(lumens), assetType: .stellar)
    }
    
    public static func lumensFromMajor(decimal lumens: Decimal) -> CryptoValue {
        return createFromMajorValue(lumens, assetType: .stellar)
    }
    
    public static func lumensFromStroops(int stroops: Int) -> CryptoValue {
        return CryptoValue(currencyType: .stellar, amount: BigInt(stroops))
    }
}

// MARK: - Number Extensions

extension BigInt {
    func decimalDivision(divisor: BigInt) -> Decimal {
        let (quotient, remainder) =  self.quotientAndRemainder(dividingBy: divisor)
        return Decimal(string: String(quotient))! + Decimal(string: String(remainder))! / Decimal(string: String(divisor))!
    }
}

extension Decimal {
    func roundTo(places: Int) -> Decimal {
        let divisor = Double(truncating: pow(10.0, places) as NSNumber)
        return Decimal(round(Double(truncating: self as NSNumber) * divisor) / divisor)
    }
}

// MARK: NumberFormatter Extension

extension NumberFormatter {
    fileprivate static func decimalStyleFormatter(
        withMinfractionDigits minfractionDigits: Int,
        maxfractionDigits: Int,
        usesGroupingSeparator: Bool
        ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.minimumFractionDigits = minfractionDigits
        formatter.maximumFractionDigits = maxfractionDigits
        formatter.roundingMode = .down
        return formatter
    }
}
