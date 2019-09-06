//
//  CoinSelectionTests.swift
//  BitcoinKitTests
//
//  Created by Jack on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import BigInt
import PlatformKit
@testable import BitcoinKit

class CoinSelectionTests: XCTestCase {
    
    private static let feePerByte = BigUInt(55)
    
    var fee: Fee!
    var calculator: TransactionSizeCalculating!
    var subject: CoinSelection!
    
    override func setUp() {
        super.setUp()
        
        fee = Fee(feePerByte: CoinSelectionTests.feePerByte)
        calculator = TransactionSizeCalculator()
        subject = CoinSelection(calculator: calculator)
    }
    
    override func tearDown() {
        fee = nil
        calculator = nil
        subject = nil
        
        super.tearDown()
    }
    
    func test_ascent_draw_selection_with_change_output() throws {
        let outputAmount = try BitcoinValue(crypto: CryptoValue.bitcoinFromSatoshis(int: 100_000))
        let coins = unspents([ 1, 20_000, 0, 0, 300_000, 50_000, 30_000 ])
        let strategy = AscentDrawSortingStrategy()
        let result = subject.select(inputs:
            CoinSelectionInputs(
                value: outputAmount,
                fee: fee,
                unspentOutputs: coins,
                sortingStrategy: strategy
            )
        )
        
        let selected = unspents([ 20_000, 30_000, 50_000, 300_000 ])
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: BigUInt(37_070),
            consumedAmount: BigUInt.zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
    
    func test_ascent_draw_selection_with_no_change_output() throws {
        let outputAmount = try BitcoinValue(crypto: CryptoValue.bitcoinFromSatoshis(int: 472_000))
        let coins = unspents([ 200_000, 300_000, 500_000 ])
        let strategy = AscentDrawSortingStrategy()
        let result = subject.select(inputs:
            CoinSelectionInputs(
                value: outputAmount,
                fee: fee,
                unspentOutputs: coins,
                sortingStrategy: strategy
            )
        )
        let selected = unspents([ 200_000, 300_000 ])
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: selected.sum() - outputAmount.amount.magnitude,
            consumedAmount: BigUInt(9_190)
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
    
    func test_descent_draw_selection_with_change_output() throws {
        let outputAmount = try BitcoinValue(crypto: CryptoValue.bitcoinFromSatoshis(int: 100_000))
        let coins = unspents([ 1, 20_000, 0, 0, 300_000, 50_000, 30_000 ])
        let strategy = DescentDrawSortingStrategy()
        let result = subject.select(inputs:
            CoinSelectionInputs(
                value: outputAmount,
                fee: fee,
                unspentOutputs: coins,
                sortingStrategy: strategy
            )
        )
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([ 300_000 ]),
            absoluteFee: BigUInt(12_485),
            consumedAmount: BigUInt.zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
    
    func test_descent_draw_selection_with_no_change_output() throws {
        let outputAmount = try BitcoinValue(crypto: CryptoValue.bitcoinFromSatoshis(int: 485_000))
        let coins = unspents([ 200_000, 300_000, 500_000 ])
        let strategy = DescentDrawSortingStrategy()
        let result = subject.select(inputs:
            CoinSelectionInputs(
                value: outputAmount,
                fee: fee,
                unspentOutputs: coins,
                sortingStrategy: strategy
            )
        )
        let selected = unspents([ 500_000 ])
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: selected.sum() - outputAmount.amount.magnitude,
            consumedAmount: BigUInt(4_385)
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
    
    func test_select_all_selection_with_effective_inputs() throws {
        let coins = unspents([ 1, 20_000, 0, 0, 300_000 ])
        let result = subject.select(all: coins, fee: fee)
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([ 20_000, 300_000 ]),
            absoluteFee: BigUInt(18_810),
            consumedAmount: BigUInt.zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
    
    func test_select_all_selection_with_no_inputs() throws {
        let coins = unspents([])
        let result = subject.select(all: coins, fee: fee)
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([]),
            absoluteFee: BigUInt.zero,
            consumedAmount: BigUInt.zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
    
    func test_select_all_selection_with_no_effective_inputs() throws {
        let coins = unspents([ 1, 10, 100 ])
        let result = subject.select(all: coins, fee: fee)
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([]),
            absoluteFee: BigUInt.zero,
            consumedAmount: BigUInt.zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
}

private func unspents(_ values: [Int]) -> [UnspentOutput] {
    return values.compactMap { value in
        guard let bitcoinValue = try? BitcoinValue(crypto: CryptoValue.bitcoinFromSatoshis(int: abs(value))) else {
            return nil
        }
        return UnspentOutput(value: bitcoinValue)
    }
}
