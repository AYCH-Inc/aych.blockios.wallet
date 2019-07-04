//
//  StellarValueTests.swift
//  StellarKitTests
//
//  Created by Jack on 02/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit
@testable import StellarKit

class StellarValueTests: XCTestCase {
    func test_initialisation() {
        let cryptoValue = CryptoValue.etherFromMajor(string: "1000.0")!
        XCTAssertThrowsError(try StellarValue(value: cryptoValue)) { error in
            XCTAssertEqual(error as! StellarValueError, StellarValueError.notAStellarValue)
        }
    }

    func test_overflow_check() {
        let cryptoValue = CryptoValue.lumensFromMajor(int: 99999999999)
        let subject = try? StellarValue(value: cryptoValue)
        XCTAssertNotNil(subject)
        XCTAssertThrowsError(try subject?.stroops()) { error in
            XCTAssertEqual(error as! StellarValueError, StellarValueError.integerOverflow)
        }
    }
    
    func test_conversion() {
        let cryptoValue = CryptoValue.lumensFromMajor(int: 100000)
        let subject = try? StellarValue(value: cryptoValue)
        XCTAssertNotNil(subject)
        XCTAssertNoThrow(try subject?.stroops())
        let stroops = try? subject?.stroops()
        XCTAssertEqual(stroops, Optional.some(Int(1000000000000)))
    }
}
