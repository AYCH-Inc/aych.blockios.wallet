//
//  CryptoValueTests.swift
//  PlatformKitTests
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class CryptoValueTests: XCTestCase {
    func testMajorValue() {
        XCTAssertEqual(Decimal(100), CryptoValue.bitcoinFromSatoshis(string: "10000000000")!.majorValue)
        XCTAssertEqual(Decimal(10), CryptoValue.bitcoinFromSatoshis(int: 1_000_000_000).majorValue)
        XCTAssertEqual(Decimal(1), CryptoValue.bitcoinFromSatoshis(int: 100_000_000).majorValue)
        XCTAssertEqual(Decimal(0.1), CryptoValue.bitcoinFromSatoshis(int: 10_000_000).majorValue)
        XCTAssertEqual(Decimal(0.01), CryptoValue.bitcoinFromSatoshis(int: 1_000_000).majorValue)
        XCTAssertEqual(Decimal(0.001), CryptoValue.bitcoinFromSatoshis(int: 100_000).majorValue)
        XCTAssertEqual(Decimal(0.0001), CryptoValue.bitcoinFromSatoshis(int: 10_000).majorValue)
        XCTAssertEqual(Decimal(0.00001), CryptoValue.bitcoinFromSatoshis(int: 1_000).majorValue)
        XCTAssertEqual(Decimal(0.000001), CryptoValue.bitcoinFromSatoshis(int: 100).majorValue)
        XCTAssertEqual(Decimal(0.0000001), CryptoValue.bitcoinFromSatoshis(int: 10).majorValue)
        XCTAssertEqual(Decimal(0.00000001), CryptoValue.bitcoinFromSatoshis(int: 1).majorValue)

        // Comparing Strings below since the value Decimal(4.90993923) will produce precision issues
        // (i.e. the underlying value will be something like 4.9099392300000234821
        XCTAssertEqual("4.90993923", "\(CryptoValue.bitcoinFromSatoshis(int: 490993923).majorValue)")
    }
    
    func testCreateFromMajor() {
        XCTAssertEqual(
            1_000_000_000,
            CryptoValue.createFromMajorValue(10, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            100_000_000,
            CryptoValue.createFromMajorValue(1, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            10_000_000,
            CryptoValue.createFromMajorValue(0.1, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            1_000_000,
            CryptoValue.createFromMajorValue(0.01, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            100_000,
            CryptoValue.createFromMajorValue(0.001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            10_000,
            CryptoValue.createFromMajorValue(0.0001, assetType: .bitcoin).amount
        )
        XCTAssertEqual(
            1_000,
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

    func testEquatable() {
        XCTAssertEqual(
            CryptoValue.createFromMajorValue(0.123, assetType: .bitcoin),
            CryptoValue.createFromMajorValue(0.123, assetType: .bitcoin)
        )
    }
    
    func testCreateFromMajorRoundOff() {
        XCTAssertEqual(
            300_000,
            CryptoValue.createFromMajorValue(0.00300000000002, assetType: .bitcoin).amount
        )
    }
}
