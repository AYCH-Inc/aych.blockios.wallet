//
//  SparklineInteracting.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxRelay
import RxSwift

public protocol SparklineInteracting {
    
    /// The currency displayed in the Sparkline
    var currency: CryptoCurrency { get }
    
    /// The window for showing the price differences over time
    var window: PriceWindow { get }
    
    /// The historical prices and balance
    /// calculation state
    var calculationState: Observable<SparklineCalculationState> { get }
    
    /// Similar to `Send`. At times the page may need to reload.
    func recalculateState()
}
