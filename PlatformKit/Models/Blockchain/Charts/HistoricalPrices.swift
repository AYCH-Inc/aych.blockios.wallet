//
//  HistoricalPrices.swift
//  PlatformKit
//
//  Created by AlexM on 9/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct HistoricalPrices {
    public let currency: CryptoCurrency
    public let delta: Decimal
    public let prices: [PriceInFiat]
    
    public init(currency: CryptoCurrency, prices: [PriceInFiat]) {
        self.currency = currency
        self.prices = prices
        if let first = prices.first, let latest = prices.last {
            let difference = latest.price - first.price
            delta = (difference / first.price) * 100
        } else {
            delta = 0
        }
    }
}
