//
//  DashboardTotalBalance.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformKit
import PlatformUIKit

struct DashboardTotalBalance {
    struct State {
        typealias Interaction = LoadingState<Value.Interaction>
        typealias Presentation = LoadingState<Value.Presentation>
    }
    
    struct Value {
        
        /// The interaction value of dashboard asset
        struct Interaction {

            /// The chart data
            let chart: [AssetPieChart.Value.Interaction]

            /// The asset / account price data
            let price: DashboardAsset.Value.Interaction.AssetPrice
        }
        
        /// The presentation value of a dashboard asset
        struct Presentation {
            
            /// The chart data
            let chart: PieChartData
            let price: DashboardAsset.Value.Presentation.AssetPrice
            
            init(with value: Interaction) {
                chart = PieChartData(with: value.chart)
                price = .init(with: value.price, descriptors: .balance)
            }
        }
    }
}
