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
    var historicalPrices: Observable<HistoricalPrices> { get }
}

public protocol HistoricalFiatPriceServiceAPI: LatestFiatPriceFetching, HistoricalFiatPriceFetching {
    
    /// The calculationState of the service. Returns a `ValueCalculationState` that
    /// contains `HistoricalPrices` and a `FiatValue` each derived from `LatestFiatPriceFetching`
    /// and `HistoricalFiatPriceFetching`.
    var calculationState: Observable<ValueCalculationState<(HistoricalPrices, FiatValue)>> { get }
    /// A trigger that force the service to fetch the updated price.
    /// Handy to call on currency type and value changes
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

public final class HistoricalFiatPriceService: HistoricalFiatPriceServiceAPI {
    
    // MARK: Typealias
    
    public typealias CalculationState = ValueCalculationState<(HistoricalPrices, FiatValue)>
    
    // MARK: HistoricalFiatPriceServiceAPI
    
    public let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: LatestFiatPriceFetching
    
    public var latestPrice: Observable<FiatValue>
    
    // MARK: HistoricalFiatPriceFetching
    
    public var historicalPrices: Observable<HistoricalPrices>
    
    public var calculationState: Observable<CalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    // MARK: Private Properties
    
    private let calculationStateRelay = BehaviorRelay<CalculationState>(value: .calculating)
    private let bag: DisposeBag = DisposeBag()
    
    // MARK: - Services
    
    /// The exchange service
    private let historicalPriceService: HistoricalPricesAPI
    
    /// The currency provider
    private let fiatCurrencyProvider: FiatCurrencyTypeProviding
    
    /// The associated asset
    private let cryptoCurrency: CryptoCurrency
    
    public init(cryptoCurrency: CryptoCurrency,
                priceWindow: PriceWindow,
                historicalPriceService: HistoricalPricesAPI = HistoricalPriceService(),
                fiatCurrencyProvider: FiatCurrencyTypeProviding) {
        self.cryptoCurrency = cryptoCurrency
        self.historicalPriceService = historicalPriceService
        self.fiatCurrencyProvider = fiatCurrencyProvider
        
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        
        let currencyProvider = Observable
            .combineLatest(fiatCurrencyProvider.fiatCurrency, fetchTriggerRelay)
            .throttle(
                .milliseconds(100),
                scheduler: scheduler
            )
            .map { $0.0 }
            .flatMapLatest { fiatCurrency -> Observable<(HistoricalPrices, String)> in
                let prices = historicalPriceService.historicalPrices(
                    within: priceWindow,
                    currency: cryptoCurrency,
                    code: fiatCurrency.code
                ).asObservable()
                return Observable.zip(prices, Observable.just(fiatCurrency.code))
            }
            .subscribeOn(scheduler)
            .observeOn(scheduler)
            .share(replay: 1)
        
        latestPrice = currencyProvider.map({ (pastPrices, code) -> FiatValue in
            if let priceInFiat = pastPrices.prices.last {
                let latest = priceInFiat.toPriceInFiatValue(currencyCode: code)
                return latest.priceInFiat
            } else {
                return .zero(currencyCode: code)
            }
        })
        
        historicalPrices = currencyProvider.map { $0.0 }
        
        Observable
            .combineLatest(latestPrice, historicalPrices)
            .map { .value(($1, $0)) }
            .startWith(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: bag)
    }
}
