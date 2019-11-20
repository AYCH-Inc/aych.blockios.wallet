//
//  BalanceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

/// Provider of balance services and total balance in `FiatValue`
public protocol BalanceProviding: class {
    
    subscript(currency: CryptoCurrency) -> AssetBalanceFetching { get }
    
    /// Streams the total fiat balance in the wallet
    var fiatBalance: Observable<FiatValueCalculationState> { get }
    
    /// Streams the fiat balances
    var fiatBalances: Observable<FiatCryptoPairCalculationStates> { get }
    
    /// Triggers a refresh on the balances
    func refresh()
}

/// A cross-asset balance provider
public final class BalanceProvider: BalanceProviding {

    // MARK: - Balance
    
    /// Reduce cross asset fiat balance values into a single fiat value
    public var fiatBalance: Observable<FiatValueCalculationState> {
        return fiatBalances
            .map { $0.totalFiat }
            .share()
    }
    
    /// Calculates all balances in `WalletBalance`
    public var fiatBalances: Observable<FiatCryptoPairCalculationStates> {
        return Observable
            .combineLatest(
                services[.ethereum]!.calculationState,
                services[.pax]!.calculationState,
                services[.stellar]!.calculationState,
                services[.bitcoin]!.calculationState,
                services[.bitcoinCash]!.calculationState
            )
            .map {
                FiatCryptoPairCalculationStates(
                    statePerCurrency: [
                        .ethereum: $0.0,
                        .pax: $0.1,
                        .stellar: $0.2,
                        .bitcoin: $0.3,
                        .bitcoinCash: $0.4
                    ]
                )
            }
            .share()
    }
    
    public subscript(currency: CryptoCurrency) -> AssetBalanceFetching {
        return services[currency]!
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: AssetBalanceFetching] = [:]
    
    // MARK: - Setup
    
    public init(ether: AssetBalanceFetching,
                pax: AssetBalanceFetching,
                stellar: AssetBalanceFetching,
                bitcoin: AssetBalanceFetching,
                bitcoinCash: AssetBalanceFetching) {
        services[.ethereum] = ether
        services[.pax] = pax
        services[.stellar] = stellar
        services[.bitcoin] = bitcoin
        services[.bitcoinCash] = bitcoinCash
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }
}
