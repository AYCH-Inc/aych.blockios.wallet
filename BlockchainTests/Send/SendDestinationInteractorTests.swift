//
//  SendDestinationInteractorTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
@testable import Blockchain

final class SendDestinationInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    // TODO: Add any supported asset to this test case
    private let assets = [AssetType.ethereum]
    
    // MARK: - Exchange Account Test Cases
    
    func testHasExchangeAccount() throws {
        for asset in assets {
            let interactor = self.interactor(for: asset, hasExchangeAccount: true)
            let hasExchangeAccount = try interactor.hasExchangeAccount.toBlocking().first()!
            XCTAssertTrue(hasExchangeAccount)
        }
    }
    
    func testExchangeAccountSelectionWhenExchangeAccountAvailable() throws {
        try testExchangeAccountSelection(when: true)
    }
    
    func testExchangeAccountSelectionWhenExchangeAccountNotAvailable() throws {
        try testExchangeAccountSelection(when: false)
    }
    
    private func testExchangeAccountSelection(when hasExchangeAccount: Bool) throws {
        for asset in assets {
            let interactor = self.interactor(for: asset, hasExchangeAccount: hasExchangeAccount)
            interactor.exchangeSelectedRelay.accept(true)
            let state = try interactor.accountState.toBlocking().first()!
            XCTAssertEqual(hasExchangeAccount, state.isValid)
        }
    }
    
    // MARK: - Manual Destination Test Cases
    
    func testInvalidDestinations() throws {
        let expectedState = SendDestinationAccountState.invalid(.format)
        for asset in assets {
            try test(destination: "hi, i'm so invalid", for: asset, expectedState: expectedState)
        }
    }
    
    func testEmptyDestinations() throws {
        let expectedState = SendDestinationAccountState.invalid(.empty)
        for asset in assets {
            try test(destination: "", for: asset, expectedState: expectedState)
        }
    }
    
    func testValidDestinations() throws {
        for asset in assets {
            let address = FakeAddress.address(for: asset)
            let expectedState = SendDestinationAccountState.valid(address: address)
            try test(destination: address, for: asset, expectedState: expectedState)
        }
    }
    
    private func test(destination: String, for asset: AssetType, expectedState: SendDestinationAccountState) throws {
        let interactor = self.interactor(for: asset, hasExchangeAccount: true)
        interactor.set(address: destination)
        
        let accountState = interactor.accountState.toBlocking()
        let state = try accountState.first()!
        
        XCTAssertEqual(state, expectedState)
    }
    
    // MARK: - Accessors
    
    private func interactor(for asset: AssetType, hasExchangeAccount: Bool) -> SendDestinationAccountInteracting {
        let exchangeAddressFetcher: ExchangeAddressFetching
        if hasExchangeAccount {
            exchangeAddressFetcher = MockExchangeAddressFetcher(expectedResult: .success(.active))
        } else {
            exchangeAddressFetcher = MockExchangeAddressFetcher(expectedResult: .success(.blocked))
        }
        return SendDestinationAccountInteractor(asset: asset, exchangeAddressFetcher: exchangeAddressFetcher)
    }
}
