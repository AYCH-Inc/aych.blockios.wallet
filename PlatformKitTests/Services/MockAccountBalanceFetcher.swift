//
//  MockAccountBalanceFetcher.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

@testable import PlatformKit

public final class MockAccountBalanceFetcher: AccountBalanceFetching {
    
    // MARK: - Properties
    
    public var balance: Single<CryptoValue> {
        return Single.just(expectedBalance)
    }
    
    public var balanceObservable: Observable<CryptoValue> {
        return balance.asObservable()
    }
    
    public let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    private let expectedBalance: CryptoValue

    // MARK: - Setup
    
    public init(expectedBalance: CryptoValue) {
        self.expectedBalance = expectedBalance
    }
}
