//
//  AssetLineChart.swift
//  Blockchain
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformKit

/// Any util / data related to the pie chart presentation / interaction layers
struct AssetLineChart {
        
    struct State {
        typealias Interaction = LoadingState<AssetLineChart.Value.Interaction>
        typealias Presentation = LoadingState<(AssetLineChartMarkerView.Theme, LineChartData)>
    }
        
    // MARK: - Value namespace
    
    struct Value {
        
        /// Value for the interaction level
        struct Interaction {
            
            /// Percent change of the dataset
            let delta: Double
            
            /// The asset type
            let currency: CryptoCurrency
            
            /// Prices for the dataset
            let prices: [PriceInFiat]
        }

        /// A presentation value
        struct Presentation: CustomDebugStringConvertible {
            
            let debugDescription: String
            
            /// The color of the asset
            let color: UIColor
            
            /// The percentage of the asset from the total of 100%
            let points: [CGPoint]
            
            init(value: Interaction) {
                debugDescription = value.currency.symbol
                color = value.delta >= 0 ? .positivePrice : .negativePrice
                points = value.prices.enumerated().map {
                    return CGPoint(x: Double($0.offset), y: $0.element.price.doubleValue)
                }
            }
        }
    }
}

extension AssetLineChart.State.Presentation {
    var visibility: Visibility {
        switch self {
        case .loading:
            return .hidden
        case .loaded:
            return .visible
        }
    }
    
    var shimmerVisibility: Visibility {
        return visibility == .hidden ? .visible : .hidden
    }
}
