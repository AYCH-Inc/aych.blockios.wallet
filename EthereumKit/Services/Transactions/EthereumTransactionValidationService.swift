//
//  EthereumTransactionValidationService.swift
//  EthereumKit
//
//  Created by AlexM on 8/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import BigInt

public class EthereumTransactionValidationService: ValidateTransactionAPI {
    private let feeService: EthereumFeeServiceAPI
    private let repository: EthereumAssetAccountRepository
    
    public init(with feeService: EthereumFeeServiceAPI,
                repository: EthereumAssetAccountRepository) {
        self.feeService = feeService
        self.repository = repository
    }
    
    public func validateCryptoAmount(amount: Crypto) -> Single<TransactionValidationResult> {
        return Single.zip(feeService.fees, balance)
            .flatMap { tuple -> Single<TransactionValidationResult> in
                let (fee, balanceSigned) = tuple
                let value: BigUInt = BigUInt(amount.amount)
                let gasPrice = BigUInt(fee.regular.amount)
                let gasLimit = BigUInt(fee.gasLimit)
                let balance = BigUInt(balanceSigned.amount)
                let transactionFee = gasPrice * gasLimit
                
                guard transactionFee < balance else {
                    return Single.just(.invalid(EthereumKitValidationError.insufficientFeeCoverage))
                }
                
                let availableBalance = balance - transactionFee
                
                guard value <= availableBalance else {
                    return Single.just(.invalid(EthereumKitValidationError.insufficientFunds))
                }
                
                return Single.just(.ok)
        }
    }
    
    private var balance: Single<CryptoValue> {
        return repository.currentAssetAccountDetails(fromCache: false).flatMap(weak: self, { (self, details) -> Single<CryptoValue> in
            return Single.just(details.balance)
        })
    }
}

