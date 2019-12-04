//
//  AssetLineChartInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import RxCocoa

final class AssetLineChartInteractor: AssetLineChartInteracting {
        
    // MARK: - Properties
    
    var state: Observable<AssetLineChart.State.Interaction> {
        return stateRelay
            .asObservable()
    }
    
    private var window: Signal<PriceWindow> {
        return priceWindowRelay.asSignal()
    }
    
    public let priceWindowRelay = PublishRelay<PriceWindow>()
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<AssetLineChart.State.Interaction>(value: .loading)
    private let currency: CryptoCurrency
    private let currencyCode: String
    private let pricesAPI: HistoricalPricesAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         code: String,
         pricesAPI: HistoricalPricesAPI = HistoricalPriceService()) {
        self.currencyCode = code
        self.pricesAPI = pricesAPI
        self.currency = currency
        setup()
    }
    
    private func setup() {
        window.emit(onNext: { [weak self] priceWindow in
            guard let self = self else { return }
            self.loadHistoricalPrices(within: priceWindow)
        })
        .disposed(by: disposeBag)
    }
    
    private func loadHistoricalPrices(within window: PriceWindow) {
        pricesAPI.historicalPrices(within: window,
                                   currency: currency,
                                   code: currencyCode).asObservable()
            .map(weak: self) { (self, result) -> (Double, [PriceInFiat]) in
                return (result.delta, result.prices)
            }
            .map { .init(delta: $0.0, currency: self.currency, prices: $0.1) }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

