//
//  NumberFormatterTests.swift
//  BlockchainTests
//
//  Created by kevinwu on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class NumberFormatterTests: XCTestCase {
    func testLocalCurrencyConversion() {
        // 2.532 ETH
        guard let amount = Decimal(string: "2.532"),
        let rate = Decimal(string: "212.23") else {
            XCTFail("Could not initialize amount or rate")
            return
        }
        let localCurrencyAmount = NumberFormatter.localCurrencyAmount(fromAmount: amount, fiatPerAmount: rate)
        XCTAssert(localCurrencyAmount == "537.37")
    }

    func testAssetConversion() {
        // $400.34
        guard let amount = Decimal(string: "400.34"),
            let rate = Decimal(string: "212.23") else {
                XCTFail("Could not initialize amount or rate")
                return
        }

        // For some reason assetType needs to be declared here
        // passing in .ethereum into line 34 causes compiler error:
        // "Ambiguous use of 'assetTypeAmount(fromAmount:fiatPerAmount:assetType:)'"
        let assetType: AssetType = .ethereum
        let assetTypeAmount = NumberFormatter.assetTypeAmount(fromAmount: amount, fiatPerAmount: rate, assetType: assetType)
        XCTAssert(assetTypeAmount == "1.88634971")
    }
}
