//
//  MockSendSourceAccountStateService.swift
//  Blockchain
//
//  Created by Daniel Huri on 11/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

@testable import Blockchain

final class MockSendSourceAccountStateService: SendSourceAccountStateServicing {

    let stateRawValue: SendSourceAccountState
    
    var state: Observable<SendSourceAccountState> {
        return Observable.just(stateRawValue)
    }

    func recalculateState() { }
    
    init(stateRawValue: SendSourceAccountState) {
        self.stateRawValue = stateRawValue
    }
}
