//
//  HistoricalFiatPriceProvider.swift
//  Blockchain
//
//  Created by AlexM on 10/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol HistoricalFiatPriceProviding: class {
    
    /// Returns the service that matches the `CryptoCurrency`
    subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI { get }
    
    /// Refreshes all the services
    func refresh()
}

public final class HistoricalFiatPriceProvider: HistoricalFiatPriceProviding {
    
    public subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI {
        return services[currency]!
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: HistoricalFiatPriceServiceAPI] = [:]
        
    // MARK: - Setup
    
    public init(window: PriceWindow,
                currencyProvider: FiatCurrencyTypeProviding) {
        services[.ethereum] = HistoricalFiatPriceService(
            cryptoCurrency: .ethereum,
            priceWindow: window,
            fiatCurrencyProvider: currencyProvider
        )
        services[.pax] = HistoricalFiatPriceService(
            cryptoCurrency: .pax,
            priceWindow: window,
            fiatCurrencyProvider: currencyProvider
        )
        services[.stellar] = HistoricalFiatPriceService(
            cryptoCurrency: .stellar,
            priceWindow: window,
            fiatCurrencyProvider: currencyProvider
        )
        services[.bitcoin] = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoin,
            priceWindow: window,
            fiatCurrencyProvider: currencyProvider
        )
        services[.bitcoinCash] = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoinCash,
            priceWindow: window,
            fiatCurrencyProvider: currencyProvider
        )
    }
        
    public func refresh() {
        services.values.forEach { $0.fetchTriggerRelay.accept(()) }
    }
}
