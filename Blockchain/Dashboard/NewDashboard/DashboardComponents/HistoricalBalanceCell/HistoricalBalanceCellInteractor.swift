//
//  HistoricalBalanceCellInteractor.swift
//  Blockchain
//
//  Created by AlexM on 10/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

final class HistoricalBalanceCellInteractor {
    
    // MARK: - Properties
    
    let priceInteractor: AssetPriceViewInteracting
    let balanceInteractor: AssetBalanceViewInteracting
    let cryptoCurrency: CryptoCurrency
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(cryptoCurrency: CryptoCurrency,
         historicalFiatPriceService: HistoricalFiatPriceServiceAPI,
         assetBalanceFetcher: AssetBalanceFetching) {
        self.cryptoCurrency = cryptoCurrency
        priceInteractor = AssetPriceViewInteractor(
            historicalPriceProvider: historicalFiatPriceService
        )
        balanceInteractor = AssetBalanceViewInteractor(
            assetBalanceFetching: assetBalanceFetcher
        )
    }
}
