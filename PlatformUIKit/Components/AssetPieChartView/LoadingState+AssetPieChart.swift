//
//  LoadingState+AssetPieChart.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformKit

extension LoadingState where Content == PieChartData {
    
    /// Initializer that receives the interaction state and
    /// maps it to `self`
    init(with state: LoadingState<[AssetPieChart.Value.Interaction]>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(let values):
            let data: PieChartData
            if (values.allSatisfy { $0.percentage.isZero }) {
                data = .empty
            } else {
                data = PieChartData(with: values)
            }
            self = .loaded(next: data)
        }
    }
}
