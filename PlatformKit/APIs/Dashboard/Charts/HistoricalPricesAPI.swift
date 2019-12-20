//
//  HistoricalPricesAPI.swift
//  PlatformKit
//
//  Created by AlexM on 9/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import NetworkKit

public protocol HistoricalPricesAPI {
    func historicalPrices(within window: PriceWindow, currency: CryptoCurrency, code: String) -> Single<HistoricalPrices>
}

public class HistoricalPriceService: HistoricalPricesAPI {
    
    private let client: APIClientAPI
    
    // MARK: - Setup
    
    // FIXME:
    // * Making this conveninence constructor `public` for now in an
    //   ideal world, the client would be provided by a `public` provider
    //   with internal properties
    public convenience init() {
        self.init(client: APIClient())
    }
    
    init(client: APIClientAPI) {
        self.client = client
    }
    
    public func historicalPrices(within window: PriceWindow, currency: CryptoCurrency, code: String) -> Single<HistoricalPrices> {
        var start: TimeInterval = 0
        var components = DateComponents()
        
        switch window {
        case .all:
            start = currency.maxStartDate
        case .day:
            components.day = -1
            start = Calendar.current.date(byAdding: components, to: Date())?.timeIntervalSince1970 ?? 0
        case .week:
            components.day = -7
            start = Calendar.current.date(byAdding: components, to: Date())?.timeIntervalSince1970 ?? 0
        case .month:
            components.month = -1
            start = Calendar.current.date(byAdding: components, to: Date())?.timeIntervalSince1970 ?? 0
        case .year:
            components.year = -1
            start = Calendar.current.date(byAdding: components, to: Date())?.timeIntervalSince1970 ?? 0
        }
        return client
            .prices(
                base: currency.symbol,
                quote: code,
                start: String(Int(start)),
                scale: String(window.scale)
            )
            .map { prices -> [PriceInFiat] in
                prices.compactMap { try? PriceInFiat(response: $0) }
            }
            .map {
                HistoricalPrices(
                    currency: currency,
                    prices: $0
                )
            }
    }
}
