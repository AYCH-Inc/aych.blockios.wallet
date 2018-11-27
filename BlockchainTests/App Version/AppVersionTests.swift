//
//  AppVersionTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 11/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class AppVersionTests: XCTestCase {

    func testIsEqual() {
        let version1 = AppVersion(string: "1.0.0")!
        let version2 = AppVersion(string: "1.0.0")!
        XCTAssertTrue(version1 == version2)
    }

    func testIsGreaterThan() {
        let version1 = AppVersion(string: "1.10.0")!
        let version2 = AppVersion(string: "1.0.0")!
        XCTAssertTrue(version1 > version2)

        let version3 = AppVersion(string: "1.10.0")!
        let version4 = AppVersion(string: "1.10.1")!
        XCTAssertFalse(version3 > version4)
    }

    func testIsGreaterThanOrEqual() {
        let version1 = AppVersion(string: "1.0.0")!
        let version2 = AppVersion(string: "1.0.0")!
        XCTAssertTrue(version1 >= version2)

        let version3 = AppVersion(string: "2.0.0")!
        let version4 = AppVersion(string: "1.10.1")!
        XCTAssertTrue(version3 >= version4)
    }

    func testIsLessThan() {
        let version1 = AppVersion(string: "0.0.3")!
        let version2 = AppVersion(string: "1.0.0")!
        XCTAssertTrue(version1 < version2)

        let version3 = AppVersion(string: "1.9.0")!
        let version4 = AppVersion(string: "1.10.1")!
        XCTAssertTrue(version3 < version4)
    }

    func testIsLessThanOrEqual() {
        let version1 = AppVersion(string: "1.0.0")!
        let version2 = AppVersion(string: "1.0.0")!
        XCTAssertTrue(version1 <= version2)

        let version3 = AppVersion(string: "1.11.0")!
        let version4 = AppVersion(string: "1.10.1")!
        XCTAssertFalse(version3 <= version4)
    }
}
