//
//  HistoricalFiatPriceResponse.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// `HistoricalFiatPriceResponse` is only used with `HistoricalFiatPriceServiceAPI`.
public struct HistoricalFiatPriceResponse {
    
    /// The prices for the given `PriceWindow`
    public let historicalPrices: HistoricalPrices
    
    /// The current `FiatValue` of the CryptoCurrency. This is **not** the `.last`
    /// value in `HistoricalPrices`. This is fetched separately from a different service.
    public let currentFiatValue: FiatValue
    
    /// The `PriceWindow`
    public let priceWindow: PriceWindow
    
    // MARK: - Init
    
    public init(prices: HistoricalPrices, fiatValue: FiatValue, priceWindow: PriceWindow) {
        self.historicalPrices = prices
        self.currentFiatValue = fiatValue
        self.priceWindow = priceWindow
    }
}
