//
//  TransactionObserving.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol TransactionObserving {
    
    /// Streams received payments
    var paymentReceived: Observable<ReceivedPaymentDetails> { get }
}
