//
//  EthereumWalletServiceMock.swift
//  EthereumKitTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import EthereumKit
import PlatformKit

class EthereumWalletServiceMock: EthereumWalletServiceAPI {
    
    var fetchHistoryIfNeededValue: Single<Void> = Single.just(())
    var fetchHistoryIfNeeded: Single<Void> {
        return fetchHistoryIfNeededValue
    }
    
    var buildTransactionValue: Single<EthereumTransactionCandidate> = Single.error(NSError())
    func buildTransaction(with value: EthereumKit.EthereumValue, to: EthereumKit.EthereumAddress) -> Single<EthereumTransactionCandidate> {
        return buildTransactionValue
    }
    
    var sendTransactionValue: Single<EthereumTransactionPublished> = Single.error(NSError())
    func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished> {
        return sendTransactionValue
    }
    var transactionValidationResult: Single<TransactionValidationResult> = Single.error(NSError())
    func evaluate(amount: EthereumValue) -> Single<TransactionValidationResult> {
        return transactionValidationResult
    }
}
