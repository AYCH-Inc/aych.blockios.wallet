//
//  MockSendExchangeService.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import PlatformKit

final class MockSendExchangeService: SendExchangeServicing {

    var fiatPrice: Observable<FiatValue> {
        let value = self.expectedValue
        return fetchTriggerRelay
            .map { _ in value }
            .startWith(value)
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private let expectedValue: FiatValue
    
    init(expectedValue: FiatValue) {
        self.expectedValue = expectedValue
    }
}
