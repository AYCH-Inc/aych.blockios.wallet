//
//  TransactionSizeCalculator.swift
//  BitcoinKit
//
//  Created by Jack on 31/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import PlatformKit

protocol TransactionSizeCalculating {
    func transactionBytes(inputs: Int, outputs: Int) -> BigUInt
    func dustThreshold(for fee: Fee) -> BigUInt
}

struct TransactionSizeCalculator: TransactionSizeCalculating {
    func transactionBytes(inputs: Int, outputs: Int) -> BigUInt {
        return CoinSelection.Constants.costBase
            + CoinSelection.Constants.costPerInput.multiplied(by: BigUInt(inputs))
            + CoinSelection.Constants.costPerOutput.multiplied(by: BigUInt(outputs))
    }
    
    func dustThreshold(for fee: Fee) -> BigUInt {
        return (CoinSelection.Constants.costPerInput + CoinSelection.Constants.costPerOutput) * fee.feePerByte
    }
}
