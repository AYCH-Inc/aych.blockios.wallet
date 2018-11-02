//
//  TransactionDetailViewModel+XLM.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// If TransactionDetailViewModel is converted to Swift, it should implement
// methods like the ones in this file to allow configuration with Swift classes/structs
extension TransactionDetailViewModel {
    convenience init(xlmTransaction: StellarOperation.Payment) {
        self.init()

        
        assetType = .stellar

        fromString = xlmTransaction.fromAccount
        fromAddress = xlmTransaction.fromAccount
        to = [xlmTransaction.toAccount]
        toString = xlmTransaction.toAccount
        
        hideNote = xlmTransaction.memo == nil
        note = xlmTransaction.memo
        txDescription = xlmTransaction.memo
        
        time = UInt64(xlmTransaction.createdAt.timeIntervalSince1970)

        amountString = xlmTransaction.amount
        
        decimalAmount = NSDecimalNumber(string: xlmTransaction.amount)
        
        if let fee = xlmTransaction.fee {
            feeString = String(describing: fee)
        }

        txType = xlmTransaction.direction == .credit ? Constants.TransactionTypes.receive : Constants.TransactionTypes.sent
        hasFromLabel = txType == Constants.TransactionTypes.sent
        hasToLabel = txType == Constants.TransactionTypes.receive
        myHash = xlmTransaction.transactionHash
        confirmed = true
        dateString = DateFormatter.verboseString(from: xlmTransaction.createdAt)
        detailButtonTitle = String(format: LocalizationConstants.Stellar.viewOnArgument, BlockchainAPI.PartnerHosts.stellarchain.rawValue).uppercased()
        detailButtonLink = BlockchainAPI.shared.stellarchainUrl.uppercased()
    }
    
    convenience init(xlmTransaction: StellarOperation.AccountCreated) {
        self.init()
        
        assetType = .stellar
        
        hideNote = xlmTransaction.memo == nil
        note = xlmTransaction.memo
        txDescription = xlmTransaction.memo
        
        fromString = xlmTransaction.account
        fromAddress = xlmTransaction.account
        to = [xlmTransaction.funder]
        toString = xlmTransaction.funder
        
        txDescription = xlmTransaction.memo
        
        time = UInt64(xlmTransaction.createdAt.timeIntervalSince1970)
        
        amountString = String(describing: xlmTransaction.balance)
        decimalAmount = xlmTransaction.balance as NSDecimalNumber
        
        if let fee = xlmTransaction.fee {
            feeString = String(describing: fee)
        }
        
        txType = xlmTransaction.direction == .credit ? Constants.TransactionTypes.receive : Constants.TransactionTypes.sent
        hasFromLabel = txType == Constants.TransactionTypes.sent
        hasToLabel = txType == Constants.TransactionTypes.receive
        myHash = xlmTransaction.transactionHash
        confirmed = true
        dateString = DateFormatter.verboseString(from: xlmTransaction.createdAt)
        detailButtonTitle = String(format: LocalizationConstants.Stellar.viewOnArgument, BlockchainAPI.PartnerHosts.stellarchain.rawValue).uppercased()
        guard let base = URL(string: BlockchainAPI.shared.stellarchainUrl) else { return }
        let stellarURL = URL.endpoint(
            base,
            pathComponents: ["tx", xlmTransaction.transactionHash],
            queryParameters: nil
        )
        detailButtonLink = stellarURL?.absoluteString
    }
}
