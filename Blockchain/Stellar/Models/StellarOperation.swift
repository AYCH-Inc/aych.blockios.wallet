//
//  StellarTradeResponse.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum StellarOperation: Identifiable {
    
    var identifier: String {
        return token
    }
    
    func cellType() -> TransactionTableCell.Type {
        return TransactionTableCell.self
    }
    
    enum Direction {
        case credit
        case debit
    }
    
    case accountCreated(AccountCreated)
    case payment(Payment)
    case unknown
    
    struct AccountCreated {
        let identifier: String
        let funder: String
        let account: String
        let direction: Direction
        let balance: Decimal
        let token: String
        let sourceAccountID: String
        let transactionHash: String
        let createdAt: Date
    }
    
    struct Payment {
        let token: String
        let identifier: String
        let fromAccount: String
        let toAccount: String
        let direction: Direction
        let amount: String
        let transactionHash: String
        let createdAt: Date
    }
}

extension StellarOperation {
    
    var transactionHash: String {
        switch self {
        case .accountCreated(let model):
            return model.transactionHash
        case .payment(let model):
            return model.transactionHash
        case .unknown:
            Logger.shared.error("Unknown Operation Type")
            return ""
        }
    }
    
    var token: String {
        switch self {
        case .accountCreated(let model):
            return model.token
        case .payment(let model):
            return model.token
        default:
            Logger.shared.error("Unknown Operation Type")
            return ""
        }
    }
    
}
