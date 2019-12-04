//
//  InstantAssetPriceViewInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay
import RxCocoa

/// `InstantAssetPriceViewInteractor` is an `AssetPriceViewInteracting`
/// that takes a `AssetLineChartUserInteracting`. This allows the view to be
/// updated with price selections as the user interacts with the `LineChartView`
final class InstantAssetPriceViewInteractor: AssetPriceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction
    
    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        return stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(historicalPriceProvider: HistoricalFiatPriceServiceAPI,
                chartUserInteracting: AssetLineChartUserInteracting) {
        Observable.combineLatest(historicalPriceProvider.calculationState, chartUserInteracting.state)
            .map { tuple -> InteractionState in
                let calculationState = tuple.0
                let userInteractionState = tuple.1
                
                switch (calculationState, userInteractionState) {
                case (.calculating, _),
                     (.invalid, _):
                    return .loading
                case (.value(let result), .deselected):
                    let delta = result.historicalPrices.delta
                    let currency = result.historicalPrices.currency
                    let window = result.priceWindow
                    let currentPrice = result.currentFiatValue
                    let fiatChange = FiatValue.create(
                        amount: result.historicalPrices.fiatChange,
                        currencyCode: result.currentFiatValue.currencyCode
                    )
                    return .loaded(
                        next: .init(
                            time: window.time(for: currency),
                            fiatValue: currentPrice,
                            changePercentage: delta,
                            fiatChange: fiatChange
                        )
                    )
                case (.value(let result), .selected(let index)):
                    let historicalPrices = result.historicalPrices
                    let currentFiatValue = result.currentFiatValue
                    let prices = Array(historicalPrices.prices[0...index])
                    let currencyCode = currentFiatValue.currencyCode
                    guard let selected = prices.last else { return .loading }
                    let priceInFiatValue = selected.toPriceInFiatValue(currencyCode: currencyCode)
                    let adjusted = HistoricalPrices(currency: historicalPrices.currency, prices: prices)
                    
                    let fiatChange = FiatValue.create(
                        amount: adjusted.fiatChange,
                        currencyCode: currencyCode
                    )
                    
                    return .loaded(
                        next: .init(
                            time: .timestamp(selected.timestamp ?? Date()),
                            fiatValue: priceInFiatValue.priceInFiat,
                            changePercentage: adjusted.delta,
                            fiatChange: fiatChange
                        )
                    )
                }
        }
        .bind(to: stateRelay)
        .disposed(by: disposeBag)
    }
}
