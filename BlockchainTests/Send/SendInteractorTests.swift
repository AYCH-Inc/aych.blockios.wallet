//
//  SendInteractorTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import PlatformKit

@testable import Blockchain

final class SendInteractorTests: XCTestCase {
    
    private enum AmountType {
        case fiat(raw: String)
        case crypto(major: String)
    }
    
    // MARK: - Properties
    
    private let assets: [AssetType] = [.ethereum]
    
    // MARK: - Success Test Cases
    
    func testSuccessfulTransferToExchangeAddress() throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            // Select PIT and set amount
            interactor.destinationInteractor.exchangeSelectedRelay.accept(true)
            interactor.set(cryptoAmount: "1")
        
            do {
                let state = try interactor.inputState.toBlocking().first()!
                XCTAssertTrue(state.isValid)
                
                try interactor.prepareForSending().toBlocking().first()!
                try interactor.send().toBlocking().first()!
            } catch {
                XCTFail("expected to successfully send crypto. got \(error) instead")
            }
        }
    }
    
    func testSuccessfulTransferToAddress() throws {
        try testSuccessfulTransferToAddress(transferredAmountType: .crypto(major: "1"))
        try testSuccessfulTransferToAddress(transferredAmountType: .fiat(raw: "1"))
    }
    
    private func testSuccessfulTransferToAddress(transferredAmountType: AmountType) throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            let address = FakeAddress.address(for: asset)
            interactor.set(address: address)
            switch transferredAmountType {
            case .crypto(major: let value):
                interactor.set(cryptoAmount: value)
            case .fiat(raw: let value):
                interactor.amountInteractor.recalculateAmounts(fromFiat: value)
            }
            
            do {
                let state = try interactor.inputState.toBlocking().first()!
                XCTAssertTrue(state.isValid)
                
                try interactor.prepareForSending().toBlocking().first()!
                try interactor.send().toBlocking().first()!
            } catch {
                XCTFail("expected to successfully transfer. got \(error) instead")
            }
        }
    }
    
    // MARK: - Failure Test Cases
   
    func testSendingToExchangeWhenAccountSelectedButMissing() throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.blocked),
                transferExecutionResult: .success(())
            )
            
            // Test sending to pit when there is no PIT connected
            interactor.destinationInteractor.exchangeSelectedRelay.accept(true)
            interactor.set(cryptoAmount: "1")
            
            do {
                let state = try interactor.inputState.toBlocking().first()!
                guard case .empty = state else {
                    XCTFail("expected transfer to fail because of empty amount. got \(state) instead")
                    return
                }
            } catch {
                XCTFail("expected transfer to fail because of empty amount. got \(error) instead")
            }
        }
    }
    
    func testSendingWithMissingAmount() throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            // Set address only but do not set an amount
            let address = FakeAddress.address(for: asset)
            interactor.set(address: address)
            
            do {
                let state = try interactor.inputState.toBlocking().first()!
                guard case .empty = state else {
                    XCTFail("expected transfer to fail because of empty amount. got \(state) instead")
                    return
                }
            } catch {
                XCTFail("expected transfer to fail because of empty amount. got \(error) instead")
            }
        }
    }
    
    func testSendingWithIncorrectAddress() throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            // Set incorrect address and amount
            interactor.set(address: "incorrect-address-format")
            interactor.set(cryptoAmount: "1")
            
            do {
                let state = try interactor.inputState.toBlocking().first()!
                guard case .invalid(.destinationAddress) = state else {
                    XCTFail("expected transfer to fail with \(SendInputState.StateError.destinationAddress). got \(state) instead")
                    return
                }
            } catch {
                XCTFail("expected transfer to fail with \(SendInputState.StateError.destinationAddress). got \(error) instead")
            }
        }
    }
    
    func testSendingWithMissingAddress() throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            interactor.amountInteractor.recalculateAmounts(fromCrypto: "1")
            
            do {
                let state = try interactor.inputState.toBlocking().first()!
                guard case .empty = state else {
                    XCTFail("expected transfer to fail because of empty destination address. got \(state) instead")
                    return
                }
            } catch {
                XCTFail("expected transfer to fail because of empty destination address. got \(error) instead")
            }
        }
    }
    
    func testSourceAccountError() {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "100",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .pendingTransactionCompletion,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            interactor.set(address: FakeAddress.address(for: asset))
            interactor.set(cryptoAmount: "1")
            
            do {
                let state = try interactor.inputState.toBlocking().first()!
                guard case .invalid(.pendingTransaction) = state else {
                    XCTFail("expected transfer to fail with \(SendInputState.StateError.pendingTransaction). got \(state) instead")
                    return
                }
            } catch {
                XCTFail("expected transfer to fail with \(SendInputState.StateError.pendingTransaction). got \(error) instead")
            }
        }
    }
    
    private func testInsufficientFeeCoverage() throws {
        try testInsufficientFeeCoverage(transferredAmountType: .crypto(major: "1"))
        try testInsufficientFeeCoverage(transferredAmountType: .fiat(raw: "1"))
    }
    
    /// This is a configurable test that allows to set amount type
    private func testInsufficientFeeCoverage(transferredAmountType: AmountType) throws {
        for asset in assets {
            let interactor = self.interactor(
                for: asset,
                balanceMajor: "1",
                feeMajor: "1",
                fiatExchangeRate: "1",
                sourceAccountStateValue: .available,
                pitAddressFetchResult: .success(.active),
                transferExecutionResult: .success(())
            )
            
            // Set address and amount
            let address = FakeAddress.address(for: asset)
            interactor.set(address: address)
            switch transferredAmountType {
            case .crypto(major: let value):
                interactor.set(cryptoAmount: value)
            case .fiat(raw: let value):
                interactor.amountInteractor.recalculateAmounts(fromFiat: value)
            }

            do {
                let state = try interactor.inputState.toBlocking().first()!
                guard case .invalid(.feeCoverage) = state else {
                    XCTFail("expected transfer to fail with \(SendInputState.StateError.feeCoverage). got \(state) instead")
                    return
                }
            } catch {
                XCTFail("expected transfer to fail with \(SendInputState.StateError.feeCoverage). got \(error) instead")
            }
        }
    }
    
    // MARK: - Accessors
    
    private func interactor(
        for asset: AssetType,
        balanceMajor: String,
        feeMajor: String,
        fiatExchangeRate: String,
        sourceAccountStateValue: SendSourceAccountState,
        pitAddressFetchResult: Result<ExchangeAddressFetcher.AddressResponseBody.State, ExchangeAddressFetcher.FetchingError>,
        transferExecutionResult: Result<Void, Error>
        ) -> SendInteracting {
        let balance = CryptoValue.createFromMajorValue(string: balanceMajor, assetType: asset.cryptoCurrency)!
        let fee = CryptoValue.createFromMajorValue(string: feeMajor, assetType: asset.cryptoCurrency)!
        let exchange = FiatValue.create(amountString: fiatExchangeRate, currencyCode: "USD")
        let services = MockSendServiceContainer(
            asset: asset,
            balance: balance,
            fee: fee,
            exchange: exchange,
            sourceAccountStateValue: sourceAccountStateValue,
            pitAddressFetchResult: pitAddressFetchResult,
            transferExecutionResult: transferExecutionResult
        )
        let interactor = SendInteractor(services: services)
        return interactor
    }
}
