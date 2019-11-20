//
//  BalanceChangeViewInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class BalanceChangeViewInteractor: AssetPriceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction

    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(balanceProvider: BalanceProviding,
                balanceChangeProvider: BalanceChangeProviding) {
        Observable
            .combineLatest(balanceProvider.fiatBalance, balanceChangeProvider.change)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { (balance, change) -> InteractionState in
                guard let currentBalance = balance.value else { return .loading }
                guard change.containsValue else { return .loading }
                guard let changeValue = change.totalFiat.value else { return .loading }
                
                let percentage: Decimal // in range [0...1]
                if currentBalance.isZero {
                    percentage = 0
                } else {
                    let previousBalance = try currentBalance - changeValue
                    
                    /// `zero` shouldn't be possible but is handled in any case
                    /// in a wa that would not throw
                    if previousBalance.isZero {
                        percentage = 0
                    } else {
                        let precentageFiat = try changeValue / previousBalance
                        percentage = precentageFiat.amount
                    }
                }
                return .loaded(
                    next: .init(
                        fiatValue: currentBalance,
                        changePercentage: percentage.doubleValue,
                        fiatChange: changeValue
                    )
                )
            }
            .catchErrorJustReturn(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
