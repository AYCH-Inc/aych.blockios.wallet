//
//  AssetPieChart.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformKit

/// Any util / data related to the pie chart presentation / interaction layers
public struct AssetPieChart {
        
    public struct State {
        public typealias Interaction = LoadingState<[AssetPieChart.Value.Interaction]>
        public typealias Presentation = LoadingState<PieChartData>
    }
        
    // MARK: - Value namespace
    
    public struct Value {
        
        /// Value for the interaction level
        public struct Interaction {
            
            /// The asset type
            let asset: CryptoCurrency
            
            /// Percentage that the asset takes off the total
            let percentage: FiatValue
        }

        /// A presentation value
        public struct Presentation: CustomDebugStringConvertible {
            
            public let debugDescription: String
            
            /// The color of the asset
            let color: UIColor
            
            /// The percentage of the asset from the total of 100%
            let percentage: Double
            
            public init(value: Interaction) {
                debugDescription = value.asset.symbol
                color = value.asset.brandColor
                percentage = Double(truncating: value.percentage.amount as NSNumber)
            }
        }
    }
}
