//
//  SendExchangeService.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import RxRelay

protocol SendExchangeServicing: class {
    
    /// The current fiat exchange price.
    /// The implementer should implement this as a `.shared(replay: 1)`
    /// resource for efficiency among multiple clients.
    var fiatPrice: Observable<FiatValue> { get }
    
    /// A trigger that force the service to fetch the updated price.
    /// Handy to call
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

final class SendExchangeService: SendExchangeServicing {
    
    // TODO: Network failure
    
    /// Fetches the fiat price, and shares its stream with other
    /// subscribers to keep external API usage count in check.
    /// Also handles currency code change
    let fiatPrice: Observable<FiatValue>
    
    /// A trigger for a fetch
    let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Services
    
    /// The exchange service
    private let priceService: PriceServiceAPI
    
    /// The currency provider
    private let fiatCurrencyProvider: FiatCurrencyTypeProviding
    
    /// The associated asset
    private let asset: AssetType
    
    // MARK: - Setup
    
    init(asset: AssetType,
         priceService: PriceServiceAPI = PriceServiceClient(),
         fiatCurrencyProvider: FiatCurrencyTypeProviding = BlockchainSettings.App.shared) {
        self.asset = asset
        self.priceService = priceService
        self.fiatCurrencyProvider = fiatCurrencyProvider
        
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        
        fiatPrice = Observable
            .combineLatest(fiatCurrencyProvider.fiatCurrency, fetchTriggerRelay)
            .throttle(.milliseconds(100), scheduler: scheduler)
            .map { $0.0.code }
            .subscribeOn(scheduler)
            .observeOn(scheduler)
            .flatMapLatest { code -> Observable<PriceInFiatValue> in
                return priceService.fiatPrice(
                        forCurrency: asset.cryptoCurrency,
                        fiatSymbol: code
                    )
                    .asObservable()
            }
            .map { $0.priceInFiat }
            .distinctUntilChanged()
            .share(replay: 1)
    }
}
