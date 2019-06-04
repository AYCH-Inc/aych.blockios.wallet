//
//  EthereumTransactionCandidateSigned.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt

enum EthereumTransactionCandidateSignedError: Error {
    case invalidTransaction
}

public struct EthereumTransactionCandidateSigned {
    
    public let transactionHash: String
    
    let transaction: web3swift.EthereumTransaction
    
    init(transaction: web3swift.EthereumTransaction) throws {
        guard let txHash = transaction.txhash else {
            throw EthereumTransactionCandidateSignedError.invalidTransaction
        }
        self.transactionHash = txHash
        self.transaction = transaction
    }
}
