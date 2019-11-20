//
//  SparklineInteractor.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import PlatformKit

public class SparklineInteractor: SparklineInteracting {
    
    // MARK: - SparklineInteracting
    
    public let window: PriceWindow
    public let currency: CryptoCurrency
    
    public var calculationState: Observable<SparklineCalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    private let calculationStateRelay = BehaviorRelay<SparklineCalculationState>(value: .invalid(.empty))
    private let disposeBag: DisposeBag = DisposeBag()
    
    public init(window: PriceWindow,
                currency: CryptoCurrency,
                fiatCurrencyProvider: FiatCurrencyTypeProviding,
                pricesAPI: HistoricalPricesAPI = HistoricalPriceService()) {
        self.currency = currency
        self.window = window
                
        fiatCurrencyProvider.fiatCurrency
            .flatMap { fiatCurrency -> Observable<HistoricalPrices> in
                pricesAPI.historicalPrices(
                    within: window,
                    currency: currency,
                    code: fiatCurrency.code
                )
                .asObservable()
            }
            .map{ result -> [Decimal] in
                let values = result.prices.map { $0.price }
                return values
            }
            .map { .value($0) }
            .startWith(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    public func recalculateState() {
        // TODO
    }
}
