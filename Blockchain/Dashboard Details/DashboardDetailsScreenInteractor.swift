//
//  DashboardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class DashboardDetailsScreenInteractor: DashboardDetailsScreenInteracting {
    let currency: CryptoCurrency
    let priceServiceAPI: HistoricalFiatPriceServiceAPI
    let currencyProvider: FiatCurrencyTypeProviding
    let balanceFetching: AssetBalanceFetching
    
    // MARK: - Init
    
    init(currency: CryptoCurrency,
         service: AssetBalanceFetching,
         currencyProvider: FiatCurrencyTypeProviding,
         exchangeAPI: PairExchangeServiceAPI,
         historicalPricesAPI: HistoricalPricesAPI = HistoricalPriceService()) {
        self.priceServiceAPI = HistoricalFiatPriceService(
            cryptoCurrency: currency,
            exchangeAPI: exchangeAPI,
            fiatCurrencyProvider: currencyProvider
        )
        self.currencyProvider = currencyProvider
        self.currency = currency
        self.balanceFetching = service
        
        priceServiceAPI.fetchTriggerRelay.accept(.week(.oneHour))
    }
    
    func refresh() {
        balanceFetching.refresh()
    }
}
