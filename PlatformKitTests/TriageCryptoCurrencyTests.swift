//
//  TriageCryptoCurrencyTests.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 20/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import Foundation
import BigInt

@testable import PlatformKit

final class TriageCryptoCurrencyTests: XCTestCase {
    
    func testCorrectDisplayOfSTX() {
        let amount = BigInt("\(10000000)")!
        let currency = TriageCryptoCurrency.blockstack
        let displayValue = currency.displayValue(amount: amount, locale: .US)
        XCTAssertEqual(displayValue, "1.0")
    }
}
