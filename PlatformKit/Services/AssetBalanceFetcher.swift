//
//  AssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public protocol AssetBalanceFetching {
    
    /// The balance service
    var balance: AccountBalanceFetching { get }
    
    /// The exchange service
    var exchange: PairExchangeServiceAPI { get }
    
    /// The calculation state of the asset balance
    var calculationState: Observable<FiatCryptoPairCalculationState> { get }
    
    /// Trigger a refresh on the balance and exchange rate
    func refresh()
}

public final class AssetBalanceFetcher: AssetBalanceFetching {
    
    // MARK: - Properties
    
    public let balance: AccountBalanceFetching
    public let exchange: PairExchangeServiceAPI
    
    /// The balance
    public var calculationState: Observable<FiatCryptoPairCalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    private let calculationStateRelay = BehaviorRelay<FiatCryptoPairCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(balance: AccountBalanceFetching,
                exchange: PairExchangeServiceAPI) {
        self.balance = balance
        self.exchange = exchange
        Observable
            .combineLatest(balance.balanceObservable, exchange.fiatPrice)
            .map { FiatCryptoPair(crypto: $0.0, exchangeRate: $0.1) }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    public func refresh() {
        balance.balanceFetchTriggerRelay.accept(())
        exchange.fetchTriggerRelay.accept(())
    }
}
