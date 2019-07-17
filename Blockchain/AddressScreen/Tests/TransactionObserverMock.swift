//
//  TransactionObserverMock.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

struct TransactionObserverMock: TransactionObserving {
    
    let paymentDetails: ReceivedPaymentDetails
    
    var paymentReceived: Observable<ReceivedPaymentDetails> {
        return .just(paymentDetails)
    }
}
