//
//  EthereumTransactionCandidateCosted.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt

public struct EthereumTransactionCandidateCosted {
    let transaction: web3swift.EthereumTransaction
    
    init(transaction: web3swift.EthereumTransaction) throws {
        guard transaction.gasPrice > 0 && transaction.gasLimit > 0 else {
            throw EthereumKitError.unknown
        }
        self.transaction = transaction
    }
}
