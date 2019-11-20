//
//  AssetSparklinePresenterFactory.swift
//  Blockchain
//
//  Created by AlexM on 10/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// A factory for `AssetSparklinePresenters`
public final class AssetSparklinePresenterFactory {
    
    public static func presenter(for currency: CryptoCurrency,
                                 fiatCurrencyProvider: FiatCurrencyTypeProviding) -> AssetSparklinePresenter {
        let interactor = SparklineInteractor(
            window: .day(.oneHour),
            currency: currency,
            fiatCurrencyProvider: fiatCurrencyProvider
        )
        return .init(with: interactor)
    }
}
