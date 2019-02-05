//
//  PriceInFiat.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Model for a quoted price by the Service-Price endpoint in fiat for a single asset type.
struct PriceInFiat: Codable {
    let timestamp: Date?
    let price: Decimal
    let volume24h: Decimal?
}

struct PriceInFiatValue {
    fileprivate let base: PriceInFiat
    fileprivate let currencyCode: String
}

extension PriceInFiatValue {
    var priceInFiat: FiatValue {
        return FiatValue.create(amount: base.price, currencyCode: currencyCode)
    }
}

extension PriceInFiat {
    static let empty: PriceInFiat = PriceInFiat(timestamp: nil, price: 0, volume24h: nil)

    func toPriceInFiatValue(currencyCode: String) -> PriceInFiatValue {
        return PriceInFiatValue(base: self, currencyCode: currencyCode)
    }
}
