//
//  MockSendFeeService.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import PlatformKit

@testable import Blockchain

final class MockSendFeeService: SendFeeServicing {
    
    var fee: Observable<CryptoValue> {
        let value = self.expectedValue
        return triggerRelay
            .map { _ in value }
            .startWith(value)
    }
    
    let triggerRelay = PublishRelay<Void>()
    
    private let expectedValue: CryptoValue
    
    init(expectedValue: CryptoValue) {
        self.expectedValue = expectedValue
    }
}
