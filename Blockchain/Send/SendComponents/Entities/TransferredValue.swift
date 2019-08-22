//
//  TransferredValue.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

/// A transferred value in crypto and fiat
struct TransferredValue: Equatable {
    let fiat: FiatValue
    let crypto: CryptoValue
    
    /// Returns a readable format of Self
    var readableFormat: String {
        let readableFiat = fiat.toDisplayString(includeSymbol: true)
        let readableCrypto = crypto.toDisplayString(includeSymbol: true)
        return "\(readableCrypto) (\(readableFiat))"
    }
    
    /// Returns `true` if the value is 0
    var isZero: Bool {
        return fiat.isZero || crypto.isZero
    }
    
    init(crypto: CryptoValue, fiat: FiatValue) {
        self.crypto = crypto
        self.fiat = fiat
    }
    
    init(crypto: CryptoValue, exchangeRate: FiatValue) {
        self.crypto = crypto
        fiat = crypto.convertToFiatValue(exchangeRate: exchangeRate)
    }
    
    init(fiat: FiatValue, priceInFiat: FiatValue, asset: AssetType) {
        self.fiat = fiat
        crypto = fiat.convertToCryptoValue(exchangeRate: priceInFiat, cryptoCurrency: asset.cryptoCurrency)
    }
    
    public static func + (lhs: TransferredValue, rhs: TransferredValue) throws -> TransferredValue {
        let crypto = try lhs.crypto + rhs.crypto
        let fiat = try lhs.fiat + rhs.fiat
        return TransferredValue(crypto: crypto, fiat: fiat)
    }
    
    static func zero(of type: AssetType, fiatCurrencyCode: String) -> TransferredValue {
        let crypto = CryptoValue.zero(assetType: type.cryptoCurrency)
        let fiat = FiatValue.zero(currencyCode: fiatCurrencyCode)
        return TransferredValue(crypto: crypto, fiat: fiat)
    }
}
