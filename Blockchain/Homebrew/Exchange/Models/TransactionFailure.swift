//
//  TransactionFailure.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// Trades that fail need to be tracked in Nabu. The only way to do this
/// is to `PUT` the failure message and txHash to Nabu.
struct TransactionFailure: Encodable {
    let txHash: String?
    let failureReason: FailureMessage
    
    struct FailureMessage: Encodable {
        let message: String
    }
    
    init(transactionID: String? = nil, message: String) {
        self.txHash = transactionID
        self.failureReason = FailureMessage(message: message)
    }
}
