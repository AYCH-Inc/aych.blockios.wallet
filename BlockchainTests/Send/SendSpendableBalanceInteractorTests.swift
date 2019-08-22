//
//  SendSpendableBalanceInteractorTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import PlatformKit

@testable import Blockchain

// Asset agnostic tests for spendable balance interaction layer
final class SendSpendableBalanceInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    private let asset = AssetType.ethereum
    private let currencyCode = "USD"
    private lazy var balance = CryptoValue.createFromMajorValue(string: "100", assetType: asset.cryptoCurrency)!
    
    func testSpendableBalanceWhenFeeIsCalculating() throws {
        let interactor = self.interactor(for: asset, balance: balance, feeState: .calculating)
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertTrue(state.isCalculating)
    }
    
    func testSpendableBalanceHigherThanFee() throws {
        let fee = feeValue(by: "1")
        let interactor = self.interactor(for: asset, balance: balance, feeState: .value(fee))
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertEqual(state.value?.crypto, try balance - fee.crypto)
    }
    
    func testSpendableBalanceEqualToFee() throws {
        let fee = feeValue(by: "100")
        let interactor = self.interactor(for: asset, balance: balance, feeState: .value(fee))
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertEqual(state.value?.crypto, try balance - fee.crypto)
    }
    
    func testSpendableBalanceLowerThanFee() throws {
        let fee = feeValue(by: "101")
        let interactor = self.interactor(for: asset, balance: balance, feeState: .value(fee))
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertEqual(state.value?.crypto, .zero(assetType: asset.cryptoCurrency))
    }
    
    // MARK: - Accessors
    
    private func feeValue(by amount: String) -> TransferredValue {
        let fiatFee = FiatValue.create(amountString: amount, currencyCode: currencyCode)
        let cryptoFee = CryptoValue.createFromMajorValue(string: amount, assetType: asset.cryptoCurrency)!
        let fee = TransferredValue(crypto: cryptoFee, fiat: fiatFee)
        return fee
    }
    
    private func interactor(for asset: AssetType,
                            balance: CryptoValue,
                            feeState: SendCalculationState) -> SendSpendableBalanceInteracting {
        let exchangeRate = FiatValue.create(amountString: "1", currencyCode: "USD")
        return SendSpendableBalanceInteractor(
            balanceFetcher: MockAccountBalanceFetcher(expectedBalance: balance),
            feeInteractor: MockSendFeeInteractor(expectedState: feeState),
            exchangeService: MockSendExchangeService(expectedValue: exchangeRate)
        )
    }
}
