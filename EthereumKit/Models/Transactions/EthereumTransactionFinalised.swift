//
//  EthereumTransactionFinalised.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt

public struct EthereumTransactionFinalised {
    
    public let transactionHash: String
    public let rawTx: String
    
    let web3swiftTransaction: web3swift.EthereumTransaction
    
    init(transaction: web3swift.EthereumTransaction, rawTx: String) {
        self.web3swiftTransaction = transaction
        self.transactionHash = transaction.txhash!
        self.rawTx = rawTx
    }
}
