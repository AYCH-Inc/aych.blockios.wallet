//
//  AssetLineChartPresenterContainer.swift
//  Blockchain
//
//  Created by AlexM on 11/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformUIKit

final class AssetLineChartPresenterContainer {
    let priceViewPresenter: AssetPriceViewPresenter
    let lineChartPresenter: AssetLineChartPresenter
    let lineChartView: LineChartView
    
    init(priceViewPresenter: AssetPriceViewPresenter,
         lineChartPresenter: AssetLineChartPresenter,
         lineChartView: LineChartView) {
        self.priceViewPresenter = priceViewPresenter
        self.lineChartPresenter = lineChartPresenter
        self.lineChartView = lineChartView
    }
}
