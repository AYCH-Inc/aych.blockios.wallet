//
//  DataProviding.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol DataProviding: class {
    
    /// Returns all the exchange providers
    var exchange: ExchangeProviding { get }
    
    /// Returns all the asset balance providers
    var balance: BalanceProviding { get }

    /// Returns all the asset balance change providers
    /// Typically used to receive a change in balance over a certain time
    /// period
    var balanceChange: BalanceChangeProviding { get }
    
    /// Returns all the historical asset price providers
    /// This service is wallet agnostic and provides the
    /// market prices over a given duration
    var historicalPrices: HistoricalFiatPriceProviding { get }
}
