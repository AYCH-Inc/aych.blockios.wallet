//
//  UnspentOutput.swift
//  BitcoinKit
//
//  Created by Jack on 29/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import BigInt

struct UnspentOutput: Equatable {
    
    var magnitude: BigUInt {
        return value.amount.magnitude
    }
    
    let value: BitcoinValue

    let isReplayable: Bool = true
    
    let isForceInclude: Bool = false
}

extension UnspentOutput {
    func effectiveValue(for fee: Fee) -> BigUInt {
        let multipliedFee = fee.feePerByte.multiplied(by: CoinSelection.Constants.costPerInput)
        let fee = max(multipliedFee, BigUInt.zero)
        guard magnitude > fee else {
            return BigUInt.zero
        }
        return magnitude - fee
    }
}

extension Array where Element == UnspentOutput {
    func sum() -> BigUInt {
        guard !isEmpty else {
            return BigUInt.zero
        }
        return map { $0.magnitude }
            .reduce(BigUInt.zero) { (value, acc) -> BigUInt in
                value + acc
            }
    }
    
    func effective(for fee: Fee) -> [UnspentOutput] {
        return filter { $0.isForceInclude || $0.effectiveValue(for: fee) > BigUInt.zero }
    }
    
    func balance(for fee: Fee, outputs: Int, calculator: TransactionSizeCalculating) -> BigUInt {
        let balance = BigInt(sum()) - BigInt(calculator.transactionBytes(inputs: count, outputs: outputs)) * BigInt(fee.feePerByte)
        guard balance > BigInt.zero else {
            return BigUInt.zero
        }
        return balance.magnitude
    }
    
    var replayProtected: Bool {
        guard let firstElement = first else {
            return false
        }
        return firstElement.isReplayable != true
    }
}
