//
//  ValidateTransactionAPI.swift
//  PlatformKit
//
//  Created by AlexM on 8/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Each asset class may have its own reason as to why a proposed transaction
/// is invalid. Insufficient funds would be an example of one that is applicable to
/// pretty much every asset class but, in cases like ETH you may have a pending transaction
/// that hasn't confirmed yet.
public protocol TransactionValidationError: Error { }

public enum PlatformKitTransactionValidationError: TransactionValidationError {
    case `default`
}

public enum TransactionValidationResult {
    /// The amount you would like to send is valid
    case ok
    /// The amount you would like to send is invalid
    case invalid(TransactionValidationError)
}

/// `ValidateTransactionAPI` takes a `Crypto`. The reason that this is not a `CryptoValue` is `ERC20TokenValue`
/// and `EthereumValue` are not `CryptoValues` though they do conform to `Crypto`. Use this API to confirm
/// that an amount you would like to send is valid. 
public protocol ValidateTransactionAPI {
    func validateCryptoAmount(amount: Crypto) -> Single<TransactionValidationResult>
}
