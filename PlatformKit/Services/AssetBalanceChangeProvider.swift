//
//  AssetBalanceChangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// A provider for balance change
public protocol AssetBalanceChangeProviding: class {
    
    /// A balance fetcher
    var balance: AssetBalanceFetching { get }
    
    /// A prices provider
    var prices: HistoricalFiatPriceServiceAPI { get }
    
    /// The measured change over a time period
    var calculationState: Observable<FiatCryptoPairCalculationState> { get }
}

public final class AssetBalanceChangeProvider: AssetBalanceChangeProviding {
    
    // MARK: - AssetBalanceChangeProviding
    
    public let balance: AssetBalanceFetching
    public let prices: HistoricalFiatPriceServiceAPI
    
    public var calculationState: Observable<FiatCryptoPairCalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let calculationStateRelay = BehaviorRelay<FiatCryptoPairCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(balance: AssetBalanceFetching,
         prices: HistoricalFiatPriceServiceAPI) {
        self.balance = balance
        self.prices = prices
        Observable
            .combineLatest(balance.calculationState, prices.calculationState)
            .map { (balance, prices) in
                guard let balanceValue = balance.value else { return .calculating }
                guard let historicalPriceValue = prices.value else { return .calculating }
                let before = try balanceValue.value(before: historicalPriceValue.0.delta)
                let value = try balanceValue - before
                return .value(value)
            }
            .catchErrorJustReturn(.calculating) // TODO: Error handling
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
