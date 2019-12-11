//
//  PinTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain
@testable import PlatformKit

class PinTests: XCTestCase {

    func testInValidPin() {
        let pin = Pin(code: 0000)
        XCTAssertFalse(pin.isValid)
    }

    func testValidPin() {
        let pin = Pin(code: 6309)
        XCTAssertTrue(pin.isValid)
    }
}
