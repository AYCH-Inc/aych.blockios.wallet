//
//  BalanceChangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BalanceChangeProviding: class {
    var ether: AssetBalanceChangeProviding { get }
    var pax: AssetBalanceChangeProviding { get }
    var stellar: AssetBalanceChangeProviding { get }
    var bitcoin: AssetBalanceChangeProviding { get }
    var bitcoinCash: AssetBalanceChangeProviding { get }
    
    var change: Observable<FiatCryptoPairCalculationStates> { get }
}

/// A service that providers a balance change in crypto fiat and percentages
public final class BalanceChangeProvider: BalanceChangeProviding {
    
    // MARK: - Services
    
    public let ether: AssetBalanceChangeProviding
    public let pax: AssetBalanceChangeProviding
    public let stellar: AssetBalanceChangeProviding
    public let bitcoin: AssetBalanceChangeProviding
    public let bitcoinCash: AssetBalanceChangeProviding
    
    public var change: Observable<FiatCryptoPairCalculationStates> {
        return Observable
            .combineLatest(
                ether.calculationState,
                pax.calculationState,
                stellar.calculationState,
                bitcoin.calculationState,
                bitcoinCash.calculationState
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
    }
    
    // MARK: - Setup
    
    public init(
        ether: AssetBalanceChangeProviding,
        pax: AssetBalanceChangeProviding,
        stellar: AssetBalanceChangeProviding,
        bitcoin: AssetBalanceChangeProviding,
        bitcoinCash: AssetBalanceChangeProviding) {
        self.ether = ether
        self.pax = pax
        self.stellar = stellar
        self.bitcoin = bitcoin
        self.bitcoinCash = bitcoinCash
    }
}
