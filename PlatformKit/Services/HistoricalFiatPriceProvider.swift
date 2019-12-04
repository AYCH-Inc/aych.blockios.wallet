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
    func refresh(window: PriceWindow)
}

public final class HistoricalFiatPriceProvider: HistoricalFiatPriceProviding {
    
    public subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI {
        return services[currency]!
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: HistoricalFiatPriceServiceAPI] = [:]
    
    // MARK: - Setup
    
    public init(ether: HistoricalFiatPriceServiceAPI,
                pax: HistoricalFiatPriceServiceAPI,
                stellar: HistoricalFiatPriceServiceAPI,
                bitcoin: HistoricalFiatPriceServiceAPI,
                bitcoinCash: HistoricalFiatPriceServiceAPI) {
        services[.ethereum] = ether
        services[.pax] = pax
        services[.stellar] = stellar
        services[.bitcoin] = bitcoin
        services[.bitcoinCash] = bitcoinCash
        
        refresh()
    }
        
    public func refresh(window: PriceWindow = .day(.oneHour)) {
        services.values.forEach { $0.fetchTriggerRelay.accept(window) }
    }
}
