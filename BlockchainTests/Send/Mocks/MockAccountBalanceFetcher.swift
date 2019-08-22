//
//  MockAccountBalanceFetcher.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

final class MockAccountBalanceFetcher: AccountBalanceFetching {
    
    // MARK: - Properties
    
    var fetchBalance: Single<CryptoValue> {
        return Single.just(expectedBalance)
    }
    
    private let expectedBalance: CryptoValue

    // MARK: - Setup
    
    init(expectedBalance: CryptoValue) {
        self.expectedBalance = expectedBalance
    }
}
