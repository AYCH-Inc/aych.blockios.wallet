//
//  SendSpendableBalanceInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import PlatformKit

/// The interaction layer for spendable balance on the send screen
protocol SendSpendableBalanceInteracting {
    
    /// Stream of the updated balance in account
    var calculationState: Observable<FiatCryptoPairCalculationState> { get }
    
    /// The crypto balance, when applicable
    var balance: Observable<FiatCryptoPair> { get }
}

// MARK: - SendSpendableBalanceInteracting (default)

extension SendSpendableBalanceInteracting {
    
    /// The balance in crypto. Elements are emitted only when the calculation state contains a valid value
    var balance: Observable<FiatCryptoPair> {
        return calculationState
            .compactMap { $0.value }
    }
}
