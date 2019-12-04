//
//  HistoricalFiatPriceService.swift
//  PlatformKit
//
//  Created by AlexM on 10/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

/// This protocol defines a `Single<FiatValue>`. It's the
/// latest Fiat price for a given asset type and is to be used
/// with the `HistoricalPricesAPI`. Basically it's the last item
/// in the array of prices returned.
public protocol LatestFiatPriceFetching: class {
    var latestPrice: Observable<FiatValue> { get }
}
/// This protocol defines a `Single<HistoricalPrices>`. It's the
/// latest Fiat price for a given asset type and is to be used
/// with the `HistoricalPricesAPI`. Basically it's the last item
/// in the array of prices returned
public protocol HistoricalFiatPriceFetching: class {
    var historicalPrices: Observable<(HistoricalPrices, PriceWindow)> { get }
}

public protocol HistoricalFiatPriceServiceAPI: LatestFiatPriceFetching, HistoricalFiatPriceFetching {
    
    /// The calculationState of the service. Returns a `ValueCalculationState` that
    /// contains `HistoricalPrices` and a `FiatValue` each derived from `LatestFiatPriceFetching`
    /// and `HistoricalFiatPriceFetching`.
    var calculationState: Observable<ValueCalculationState<(HistoricalFiatPriceResponse)>> { get }
    /// A trigger that force the service to fetch the updated price.
    /// Handy to call on currency type and value changes
    var fetchTriggerRelay: PublishRelay<PriceWindow> { get }
}

public final class HistoricalFiatPriceService: HistoricalFiatPriceServiceAPI {
    
    // MARK: Typealias
    
    public typealias CalculationState = ValueCalculationState<(HistoricalFiatPriceResponse)>
    
    // MARK: HistoricalFiatPriceServiceAPI
    
    public let fetchTriggerRelay = PublishRelay<PriceWindow>()
    
    // MARK: LatestFiatPriceFetching
    
    public var latestPrice: Observable<FiatValue> {
        return exchangeAPI.fiatPrice
    }
    
    // MARK: HistoricalFiatPriceFetching
    
    public var historicalPrices: Observable<(HistoricalPrices, PriceWindow)>
    
    public var calculationState: Observable<CalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    // MARK: Private Properties
    
    private let calculationStateRelay = BehaviorRelay<CalculationState>(value: .calculating)
    private let bag: DisposeBag = DisposeBag()
    
    // MARK: - Services
    
    /// The historical price service
    private let historicalPriceService: HistoricalPricesAPI
    
    /// The exchange service
    private let exchangeAPI: PairExchangeServiceAPI
    
    /// The currency provider
    private let fiatCurrencyProvider: FiatCurrencyTypeProviding
    
    /// The associated asset
    private let cryptoCurrency: CryptoCurrency
    
    public init(cryptoCurrency: CryptoCurrency,
                exchangeAPI: PairExchangeServiceAPI,
                historicalPriceService: HistoricalPricesAPI = HistoricalPriceService(),
                fiatCurrencyProvider: FiatCurrencyTypeProviding) {
        self.exchangeAPI = exchangeAPI
        self.cryptoCurrency = cryptoCurrency
        self.historicalPriceService = historicalPriceService
        self.fiatCurrencyProvider = fiatCurrencyProvider
        
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        
        let currencyProvider = Observable
            .combineLatest(fiatCurrencyProvider.fiatCurrency, fetchTriggerRelay)
            .throttle(.milliseconds(100), scheduler: scheduler)
            .map { ($0.0, $0.1) }
            .flatMapLatest { tuple -> Observable<(HistoricalPrices, String, PriceWindow)> in
                let fiatCurrency = tuple.0
                let window = tuple.1
                let prices = historicalPriceService.historicalPrices(
                    within: window,
                    currency: cryptoCurrency,
                    code: fiatCurrency.code
                ).asObservable()
                return Observable.zip(prices, Observable.just(fiatCurrency.code), Observable.just(window))
            }
            .subscribeOn(scheduler)
            .observeOn(scheduler)
            .share(replay: 1)
        
        historicalPrices = currencyProvider.map { ($0.0, $0.2) }
        
        Observable
            .combineLatest(latestPrice, historicalPrices)
            .map {
                .value(HistoricalFiatPriceResponse(prices: $0.1.0, fiatValue: $0.0, priceWindow: $0.1.1))
            }
            .startWith(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: bag)
    }
}
