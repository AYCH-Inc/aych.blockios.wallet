//
//  CryptoValueTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 11/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class CryptoValueTests: XCTestCase {
    func testMajorValue() {
        XCTAssertEqual(Decimal(10), CryptoValue.bitcoinFromSatoshis(int: 1000000000).majorValue)
        XCTAssertEqual(Decimal(1), CryptoValue.bitcoinFromSatoshis(int: 100000000).majorValue)
        XCTAssertEqual(Decimal(0.1), CryptoValue.bitcoinFromSatoshis(int: 10000000).majorValue)
        XCTAssertEqual(Decimal(0.01), CryptoValue.bitcoinFromSatoshis(int: 1000000).majorValue)
        XCTAssertEqual(Decimal(0.001), CryptoValue.bitcoinFromSatoshis(int: 100000).majorValue)
        XCTAssertEqual(Decimal(0.0001), CryptoValue.bitcoinFromSatoshis(int: 10000).majorValue)
        XCTAssertEqual(Decimal(0.00001), CryptoValue.bitcoinFromSatoshis(int: 1000).majorValue)
        XCTAssertEqual(Decimal(0.000001), CryptoValue.bitcoinFromSatoshis(int: 100).majorValue)
        XCTAssertEqual(Decimal(0.0000001), CryptoValue.bitcoinFromSatoshis(int: 10).majorValue)
        XCTAssertEqual(Decimal(0.00000001), CryptoValue.bitcoinFromSatoshis(int: 1).majorValue)
        XCTAssertEqual(Decimal(0.00000001), CryptoValue.bitcoinFromSatoshis(int: 1).majorValue)
        XCTAssertEqual(Decimal(4.90993923), CryptoValue.bitcoinFromSatoshis(int: 490993923).majorValue)
    }

    func testCreateFromMajor() {
        XCTAssertEqual(
            1000000000,
            CryptoValue.createFromMajorValue(10, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            100000000,
            CryptoValue.createFromMajorValue(1, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            10000000,
            CryptoValue.createFromMajorValue(0.1, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            1000000,
            CryptoValue.createFromMajorValue(0.01, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            100000,
            CryptoValue.createFromMajorValue(0.001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            10000,
            CryptoValue.createFromMajorValue(0.0001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            1000,
            CryptoValue.createFromMajorValue(0.00001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            100,
            CryptoValue.createFromMajorValue(0.000001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            10,
            CryptoValue.createFromMajorValue(0.0000001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            1,
            CryptoValue.createFromMajorValue(0.00000001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            490993923,
            CryptoValue.createFromMajorValue(4.90993923, assetType: .bitcoin).amount
        )
    }

    func testIsZero() {
        XCTAssertTrue(CryptoValue.createFromMajorValue(0, assetType: .bitcoin).isZero)
        XCTAssertFalse(CryptoValue.createFromMajorValue(0.1, assetType: .bitcoin).isZero)
    }

    func testIsPositive() {
        XCTAssertTrue(CryptoValue.createFromMajorValue(0, assetType: .bitcoin).isPositive)
        XCTAssertTrue(CryptoValue.createFromMajorValue(0.1, assetType: .bitcoin).isPositive)
        XCTAssertFalse(CryptoValue.createFromMajorValue(-0.1, assetType: .bitcoin).isPositive)
    }

    func testCreateFromMajorRoundOff() {
        XCTAssertEqual(
            300000,
            CryptoValue.createFromMajorValue(0.00300000000002, assetType: .bitcoin).amount
        )
    }
}
