//
//  EthereumTransactionPublished.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt

enum EthereumTransactionPublishedError: Error {
    case invalidResponseHash
}

public struct EthereumTransactionPublished {
    public let transactionHash: String
    
    let web3swiftTransaction: web3swift.EthereumTransaction
    
    init(finalisedTransaction: EthereumTransactionFinalised, responseHash: String) throws {
        guard finalisedTransaction.transactionHash == responseHash else {
            throw EthereumTransactionPublishedError.invalidResponseHash
        }
        self.init(
            finalisedTransaction: finalisedTransaction,
            transactionHash: finalisedTransaction.transactionHash
        )
    }
    
    init(finalisedTransaction: EthereumTransactionFinalised, transactionHash: String) {
        self.web3swiftTransaction = finalisedTransaction.web3swiftTransaction
        self.transactionHash = transactionHash
    }
}
