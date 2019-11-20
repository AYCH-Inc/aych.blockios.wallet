//
//  AssetPieChartInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class AssetPieChartInteractor: AssetPieChartInteracting {
        
    // MARK: - Properties
    
    public var state: Observable<AssetPieChart.State.Interaction> {
        return stateRelay
            .asObservable()
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<AssetPieChart.State.Interaction>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    public init(balanceProvider: BalanceProviding) {
        Observable
            .combineLatest(balanceProvider.fiatBalances, balanceProvider.fiatBalance)
            .map { (balances, totalBalance) in
                guard let total = totalBalance.value else {
                    return .loading
                }
                guard total.isPositive else {
                    let zero = FiatValue.zero(currencyCode: total.currencyCode)
                    return .loaded(
                        next: [
                            .init(asset: .bitcoin, percentage: zero),
                            .init(asset: .ethereum, percentage: zero),
                            .init(asset: .bitcoinCash, percentage: zero),
                            .init(asset: .stellar, percentage: zero),
                            .init(asset: .pax, percentage: zero)
                        ]
                    )
                }
                guard let bitcoin = balances[.bitcoin].value?.fiat else {
                    return .loading
                }
                guard let bitcoinCash = balances[.bitcoinCash].value?.fiat else {
                    return .loading
                }
                guard let ether = balances[.ethereum].value?.fiat else {
                    return .loading
                }
                guard let pax = balances[.pax].value?.fiat else {
                    return .loading
                }
                guard let stellar = balances[.stellar].value?.fiat else {
                    return .loading
                }
                let next: [AssetPieChart.Value.Interaction] = [
                    .init(asset: .bitcoin, percentage: try bitcoin / total),
                    .init(asset: .ethereum, percentage: try ether / total),
                    .init(asset: .bitcoinCash, percentage: try bitcoinCash / total),
                    .init(asset: .stellar, percentage: try stellar / total),
                    .init(asset: .pax, percentage: try pax / total)
                ]
                return .loaded(next: next)
            }
            .catchErrorJustReturn(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }    
}
