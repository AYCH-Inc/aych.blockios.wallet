//
//  CoinSelection.swift
//  BitcoinKit
//
//  Created by Jack on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import BigInt

struct Fee {
    // FIXME: Should this be a BitcoinValue?
    let feePerByte: BigUInt
}

struct CoinSelectionInputs {
    let value: BitcoinValue
    let fee: Fee
    let unspentOutputs: [UnspentOutput]
    let sortingStrategy: CoinSortingStrategy
}

enum CoinSelectionError: Error {
    case noEffectiveCoins
}

protocol CoinSelector {
   func select(inputs: CoinSelectionInputs) -> Result<SpendableUnspentOutputs, CoinSelectionError>
   func select(all coins: [UnspentOutput], fee: Fee, sortingStrategy: CoinSortingStrategy?) -> Result<SpendableUnspentOutputs, CoinSelectionError>
}

class CoinSelection: CoinSelector {
    
    struct Constants {
        static let costBase: BigUInt = BigUInt(10)
        static let costPerInput: BigUInt = BigUInt(149)
        static let costPerOutput: BigUInt = BigUInt(34)
    }
    
    private let calculator: TransactionSizeCalculating
    
    init(calculator: TransactionSizeCalculating = TransactionSizeCalculator()) {
        self.calculator = calculator
    }
    
    func select(inputs: CoinSelectionInputs) -> Result<SpendableUnspentOutputs, CoinSelectionError> {
        let outputAmount = inputs.value.amount.magnitude
        let fee = inputs.fee
        let sortingStrategy = inputs.sortingStrategy
        let unspentOutputs = inputs.unspentOutputs
        let feePerByte = fee.feePerByte
        let effectiveCoins = sortingStrategy
            .sort(coins: unspentOutputs)
            .effective(for: fee)
        
        guard !effectiveCoins.isEmpty else {
            return .failure(.noEffectiveCoins)
        }
        
        var selected = [UnspentOutput]()
        var accumulatedValue = BigUInt.zero
        var accumulatedFee = BigUInt.zero
        
        for coin in effectiveCoins {
            if !coin.isForceInclude && accumulatedValue >= outputAmount + accumulatedFee {
                continue
            }
            
            selected += [ coin ]
            accumulatedValue = selected.sum()
            accumulatedFee = calculator.transactionBytes(inputs: selected.count, outputs: 1) * feePerByte
        }
        
        let dust = calculator.dustThreshold(for: fee)
        
        let remainingValueSigned = BigInt(accumulatedValue) - BigInt(outputAmount + accumulatedFee)
        let isReplayProtected = selected.replayProtected
        
        // Either there were no effective coins or we were not able to meet the target value
        if selected.isEmpty || remainingValueSigned < BigUInt.zero {
            let outputs = SpendableUnspentOutputs(isReplayProtected: isReplayProtected)
            return .success(outputs)
        }
        
        let remainingValue = remainingValueSigned.magnitude
        
        // Remaining value is worth keeping, add change output
        if remainingValue >= dust {
            accumulatedFee = calculator.transactionBytes(inputs: selected.count, outputs: 2) * feePerByte
            let outputs = SpendableUnspentOutputs(
                spendableOutputs: selected,
                absoluteFee: accumulatedFee,
                isReplayProtected: isReplayProtected
            )
            return .success(outputs)
        }
        
        // Remaining value is not worth keeping, consume it as part of the fee
        let outputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: accumulatedFee + remainingValue,
            consumedAmount: remainingValue,
            isReplayProtected: isReplayProtected
        )
        return .success(outputs)
    }
    
    func select(all coins: [UnspentOutput], fee: Fee, sortingStrategy: CoinSortingStrategy? = nil) -> Result<SpendableUnspentOutputs, CoinSelectionError> {
        let effectiveCoins = (sortingStrategy?.sort(coins: coins) ?? coins)
            .effective(for: fee)
        let effectiveValue = effectiveCoins.sum()
        let effectiveBalance = max(effectiveCoins.balance(for: fee, outputs: 1, calculator: calculator), BigUInt.zero)
        let outputs = SpendableUnspentOutputs(
            spendableOutputs: effectiveCoins,
            absoluteFee: effectiveValue - effectiveBalance,
            isReplayProtected: effectiveCoins.replayProtected
        )
        return .success(outputs)
    }
}
