//
//  HistoricalBalanceInteracting.swift
//  Blockchain
//
//  Created by AlexM on 10/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

/// The interaction protocol for the balance
/// and historical prices cell on the dashboard
protocol HistoricalAmountInteracting {
    /// The historical prices and balance
    /// calculation state
    var state: Observable<DashboardAsset.State.AssetPrice.Interaction> { get }
}
