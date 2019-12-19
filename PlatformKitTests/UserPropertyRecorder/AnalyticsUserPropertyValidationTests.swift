//
//  AnalyticsUserPropertyValidationTests.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 02/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

import ToolKit
@testable import PlatformKit

final class AnalyticsUserPropertyValidationTests: XCTestCase {
    
    private let validator = AnalyticsUserPropertyValidator()
    
    func testNameValidationSuccess() {
        do {
            try validator.validate(name: StandardUserProperty.Key.kycCreationDate.rawValue)
            try validator.validate(name: StandardUserProperty.Key.walletCreationDate.rawValue)
            try validator.validate(name: StandardUserProperty.Key.kycLevel.rawValue)
            try validator.validate(name: HashedUserProperty.Key.walletID.rawValue)
        } catch {
            XCTFail("expected success, got: \(error)")
        }
    }
    
    func testMaxLengthNameValidationSuccess() {
        do {
            let maxLengthName = (1...AnalyticsUserPropertyValidator.UserPropertyMaxLength.name)
                .map { _ in "a" }
                .joined()
            try validator.validate(name: maxLengthName)
        } catch {
            XCTFail("expected success, got: \(error)")
        }
    }
    
    func testMaxLengthNameValidationFailure() {
        do {
            let maxLengthName = (1...AnalyticsUserPropertyValidator.UserPropertyMaxLength.name + 1)
                .map { _ in "a" }
                .joined()
            try validator.validate(name: maxLengthName)
            XCTFail("expected failure. got success instead")
        } catch {}
    }
    
    func testNameFormatFailure() {
        do {
            try validator.validate(name: "1234event")
            XCTFail("expected failure. got success instead")
        } catch {}
    }
    
    func testMaxLengthValueValidationSuccess() {
        do {
            let maxLengthValue = (1...AnalyticsUserPropertyValidator.UserPropertyMaxLength.value)
                .map { _ in "a" }
                .joined()
            try validator.validate(value: maxLengthValue)
        } catch {
            XCTFail("expected success, got: \(error)")
        }
    }
    
    func testMaxLengthValueValidationFailure() {
        do {
            let maxLengthValue = (1...AnalyticsUserPropertyValidator.UserPropertyMaxLength.value + 1)
                .map { _ in "a" }
                .joined()
            try validator.validate(value: maxLengthValue)
            XCTFail("expected failure. got success instead")
        } catch {}
    }
}
