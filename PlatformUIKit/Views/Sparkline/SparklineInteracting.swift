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

public protocol SparklineInteracting: class {
    
    /// The currency displayed in the Sparkline
    var cryptoCurrency: CryptoCurrency { get }
        
    /// The historical prices and balance
    /// calculation state
    var calculationState: Observable<SparklineCalculationState> { get }
}
