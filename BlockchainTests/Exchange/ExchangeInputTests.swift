//
//  ExchangeInputTests.swift
//  BlockchainTests
//
//  Created by AlexM on 3/15/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit
@testable import Blockchain

class ExchangeInputTests: XCTestCase {
    let viewModel = ExchangeInputViewModel(inputType: .fiat)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitialFiatInputState() {
        let value = viewModel.currentValue()
        XCTAssertEqual("$0", value)
    }
    
    func testInitialNonFiatState() {
        viewModel.update(inputType: .nonfiat(.bitcoin), with: "0")
        let value = viewModel.currentValue()
        XCTAssertEqual("0 BTC", value)
    }
    
    func testFiatWholeValueEntry() {
        viewModel.append(character: "0")
        viewModel.append(character: "1")
        viewModel.append(character: "2")
        viewModel.dropLast()
        viewModel.append(character: "3")
        let value = viewModel.currentValue()
        XCTAssertEqual("$13", value)
    }
    
    func testFiatWithDelimiter() {
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "1")
        viewModel.append(character: "3")
        let value = viewModel.currentValue()
        XCTAssertEqual("$456" + (Locale.current.decimalSeparator ?? ".") + "13", value)
    }
    
    func testCryptoInputUpdate() {
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "1")
        viewModel.append(character: "3")
        viewModel.update(inputType: .nonfiat(.bitcoin), with: "123" + (Locale.current.decimalSeparator ?? ".") + "123")
        let value = viewModel.currentValue()
        XCTAssertEqual("123" + (Locale.current.decimalSeparator ?? ".") + "123 BTC", value)
    }
    
    func testCryptoTrailingZeros() {
        viewModel.inputType = .nonfiat(.bitcoin)
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "1")
        viewModel.append(character: "3")
        viewModel.append(character: "0")
        viewModel.append(character: "0")
        let value = viewModel.currentValue()
        XCTAssertEqual("456" + (Locale.current.decimalSeparator ?? ".") + "1300 BTC", value)
    }
    
    func testCryptoValueWithTrailingZeros() {
        viewModel.inputType = .nonfiat(.bitcoin)
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "1")
        viewModel.append(character: "3")
        viewModel.append(character: "0")
        viewModel.append(character: "0")
        let cryptoValue = viewModel.cryptoValue()
        XCTAssertNotNil(cryptoValue)
    }
    
    func testFiatValueWithTrailingZeros() {
        viewModel.inputType = .fiat
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "1")
        viewModel.append(character: "3")
        viewModel.append(character: "0")
        viewModel.append(character: "0")
        let fiatValue = viewModel.fiatValue()
        XCTAssertNotNil(fiatValue)
        guard let fiat = fiatValue else { return }
        let value = fiat.toDisplayString(includeSymbol: false, locale: .current)
        XCTAssertEqual("456" + (Locale.current.decimalSeparator ?? ".") + "13", value)
    }
    
    func testFiatValueWithDelimiter() {
        viewModel.inputType = .fiat
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        let fiatValue = viewModel.fiatValue()
        XCTAssertNotNil(fiatValue)
        guard let fiat = fiatValue else { return }
        let value = fiat.toDisplayString(includeSymbol: false, locale: .current)
        XCTAssertEqual("456" + (Locale.current.decimalSeparator ?? ".") + "00", value)
    }
    
    func testCurrentCryptoInputWithDelimiter() {
        viewModel.inputType = .nonfiat(.bitcoin)
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        let value = viewModel.currentValue()
        XCTAssertEqual("456" + (Locale.current.decimalSeparator ?? ".") + "0 BTC", value)
    }
    
    func testCurrentFiatInputWithDelimiter() {
        viewModel.inputType = .fiat
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        let value = viewModel.currentValue()
        XCTAssertEqual("$456" + (Locale.current.decimalSeparator ?? ".") + "0", value)
    }
    
    func testCurrentFiatInputWithDelimiterAndOneZero() {
        viewModel.inputType = .fiat
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "0")
        let value = viewModel.currentValue()
        XCTAssertEqual("$456" + (Locale.current.decimalSeparator ?? ".") + "0", value)
    }
    
    func testCurrentCryptoInputWithDelimiterAndOneZero() {
        viewModel.inputType = .nonfiat(.bitcoin)
        viewModel.append(character: "4")
        viewModel.append(character: "5")
        viewModel.append(character: "6")
        viewModel.appendDelimiter()
        viewModel.append(character: "0")
        let value = viewModel.currentValue()
        XCTAssertEqual("456" + (Locale.current.decimalSeparator ?? ".") + "0 BTC", value)
    }
    
    func testDoubleDelimiter() {
        viewModel.inputType = .nonfiat(.bitcoin)
        viewModel.append(character: "1")
        viewModel.appendDelimiter()
        viewModel.appendDelimiter()
        viewModel.append(character: "0")
        let value = viewModel.currentValue()
        XCTAssertEqual("1" + (Locale.current.decimalSeparator ?? ".") + "0 BTC", value)
    }
    
    func testTogglingInputType() {
        viewModel.inputType = .fiat
        viewModel.append(character: "1")
        viewModel.appendDelimiter()
        viewModel.append(character: "1")
        viewModel.append(character: "2")
        viewModel.update(inputType: .nonfiat(.bitcoin), with: "0" + (Locale.current.decimalSeparator ?? ".") +  "45678")
        XCTAssertEqual("0" + (Locale.current.decimalSeparator ?? ".") + "45678 BTC", viewModel.currentValue())
    }
}
