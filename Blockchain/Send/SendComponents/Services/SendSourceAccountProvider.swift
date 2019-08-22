//
//  SendSourceAccountProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Provider protocol for a source account on the send screen
protocol SendSourceAccountProviding {
    var accounts: [SendSourceAccount] { get }
    func account(by index: Int) -> SendSourceAccount
    var `default`: SendSourceAccount { get }
}

extension SendSourceAccountProviding {
    func account(by index: Int) -> SendSourceAccount {
        return accounts[index]
    }
    
    var `default`: SendSourceAccount {
        return account(by: 0)
    }
}

// MARK: - Asset Specific

class EtherSendSourceAccountProvider: SendSourceAccountProviding {
    let accounts = [SendSourceAccount(label: LocalizationConstants.myEtherWallet)]
}
