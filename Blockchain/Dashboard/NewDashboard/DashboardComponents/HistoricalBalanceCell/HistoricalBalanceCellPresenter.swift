//
//  HistoricalBalanceCellPresenter.swift
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

final class HistoricalBalanceCellPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell
    
    var thumbnail: Driver<ImageViewContent> {
        return .just(
            .init(
                image: interactor.cryptoCurrency.logo,
                accessibility: .id("\(AccessibilityId.assetImageView)\(interactor.cryptoCurrency.symbol)")
            )
        )
    }
    
    var name: Driver<LabelContent> {
        return .just(
            .init(
                text: interactor.cryptoCurrency.description,
                font: .mainSemibold(20),
                color: .dashboardAssetTitle,
                accessibility: .id("\(AccessibilityId.titleLabelFormat)\(interactor.cryptoCurrency.symbol)")
            )
        )
    }
    
    let pricePresenter: AssetPriceViewPresenter
    let sparklinePresenter: AssetSparklinePresenter
    let balancePresenter: AssetBalanceViewPresenter
    
    var cryptoCurrency: CryptoCurrency {
        return interactor.cryptoCurrency
    }
    
    private let interactor: HistoricalBalanceCellInteractor
    
    init(interactor: HistoricalBalanceCellInteractor) {
        self.interactor = interactor
        sparklinePresenter = AssetSparklinePresenter(
            with: interactor.sparklineInteractor
        )
        pricePresenter = AssetPriceViewPresenter(
            interactor: interactor.priceInteractor,
            descriptors: .assetPrice(accessibilityIdSuffix: interactor.cryptoCurrency.symbol)
        )
        balancePresenter = AssetBalanceViewPresenter(
            interactor: interactor.balanceInteractor
        )
    }
}
