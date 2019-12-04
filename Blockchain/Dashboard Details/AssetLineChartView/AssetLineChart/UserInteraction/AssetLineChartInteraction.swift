//
//  AssetLineChartInteraction.swift
//  Blockchain
//
//  Created by AlexM on 11/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum AssetLineChartInteractionState: Equatable {
    typealias Index = Int
    
    /// The `LineChartView` is no longer selected
    case deselected
    
    /// A `selected` index in a `LineChartView`
    case selected(Index)
}

extension AssetLineChartInteractionState {
    static func ==(lhs: AssetLineChartInteractionState, rhs: AssetLineChartInteractionState) -> Bool {
        switch (lhs, rhs) {
        case (.deselected, .deselected):
            return true
        case (.selected(let left), .selected(let right)):
            return left == right
        default:
            return false
        }
    }
}
