//
//  HistoricalPrices.swift
//  PlatformKit
//
//  Created by AlexM on 9/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct AssetPriceHistory {
    let current: FiatValue
}

public struct HistoricalPrices {
    public let currency: CryptoCurrency
        
    /// The difference in percentage between the latest price to the first price
    public let delta: Double
    public let prices: [PriceInFiat]
    public let fiatChange: Decimal
    
    public init(currency: CryptoCurrency, prices: [PriceInFiat]) {
        self.currency = currency
        self.prices = prices
        if let first = prices.first, let latest = prices.last {
            fiatChange = latest.price - first.price
            delta = fiatChange.doubleValue / first.price.doubleValue
        } else {
            fiatChange = 0
            delta = 0
        }
    }
}
