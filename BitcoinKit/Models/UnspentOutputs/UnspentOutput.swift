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
    
    struct XPub: Equatable {
        let m: String
        let path: String
    }
    
    var magnitude: BigUInt {
        return value.amount.magnitude
    }

    let hash: String
    
    let script: String
    
    let value: BitcoinValue
    
    let confirmations: UInt
    
    let transactionIndex: Int
    
    let xpub: XPub

    let isReplayable: Bool
    
    let isForceInclude: Bool
    
    init(hash: String,
         script: String,
         value: BitcoinValue,
         confirmations: UInt,
         transactionIndex: Int,
         xpub: XPub,
         isReplayable: Bool,
         isForceInclude: Bool = false) {
        self.hash = hash
        self.script = script
        self.value = value
        self.confirmations = confirmations
        self.transactionIndex = transactionIndex
        self.xpub = xpub
        self.isReplayable = isReplayable
        self.isForceInclude = isForceInclude
    }
}

extension UnspentOutput {
    init(response: UnspentOutputResponse) throws {
        let satoshisString = NSDecimalNumber(decimal: response.value).stringValue
        guard
            let satoshis = BigInt(satoshisString)
        else {
            throw UnspentOutputError.invalidValue
        }
        let value = try BitcoinValue(satoshis: satoshis)
        self.hash = response.tx_hash
        self.script = response.script
        self.value = value
        self.confirmations = response.confirmations
        self.transactionIndex = response.tx_index
        self.xpub = XPub(responseXPub: response.xpub)
        self.isReplayable = response.replayable ?? false
        self.isForceInclude = false
    }
}

extension UnspentOutput.XPub {
    init(responseXPub: UnspentOutputResponse.XPub) {
        self.m = responseXPub.m
        self.path = responseXPub.path
    }
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
