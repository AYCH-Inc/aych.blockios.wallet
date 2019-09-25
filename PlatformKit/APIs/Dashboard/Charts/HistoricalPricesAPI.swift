//
//  HistoricalPricesAPI.swift
//  PlatformKit
//
//  Created by AlexM on 9/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol HistoricalPricesAPI {
    func historicalPrices(within window: PriceWindow) -> Single<HistoricalPrices>
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
    
    public func historicalPrices(within window: PriceWindow) -> Single<HistoricalPrices> {
        return client.prices(within: window).map {
            HistoricalPrices(
                currency: window.currency,
                prices: $0
            )
        }
    }
}
