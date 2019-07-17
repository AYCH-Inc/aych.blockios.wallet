//
//  DigitPadButtonViewModelTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import Blockchain

/// Testing `DigitPadViewModel`'s functionality
class DigitPadViewModelTests: XCTestCase {
    
    // Legal inputs to go through in testing.
    private var legalLengthTestInputs: [String] {
        return ["1", "31", "40", "123", "9999", "443", "001"]
    }
    
    private let bag = DisposeBag()
    
    // Tests reseting the digit code value to a given digit sequence
    func testReset() {
        let viewModel = DigitPadViewModel()
        let expectedValue = legalLengthTestInputs.randomElement()!
        viewModel.reset(to: expectedValue)
        XCTAssertEqual(viewModel.value, expectedValue)
    }
    
    // Testing of observing input length
    func testValueLengthObserving() throws {
        for input in legalLengthTestInputs {
            let viewModel = DigitPadViewModel()
            viewModel.reset(to: input)
            let result = try viewModel.valueLengthObservable.toBlocking().first()
            let expected = input.count
            XCTAssertEqual(result, expected)
        }
    }

    /// Tests accumulation inputs
    func testAccumulatedInput() throws {
        for input in legalLengthTestInputs {
            let viewModel = DigitPadViewModel()
            let digitViewModels = viewModel.digitButtonViewModelArray
            let blockingValueObservable = viewModel.valueObservable.toBlocking()
            for char in input {
                let numericValue = Int(String(char))!
                digitViewModels[numericValue].tap()
                let result = try blockingValueObservable.first()?.last
                XCTAssertEqual(char, result)
            }
            let result = try blockingValueObservable.first()
            XCTAssertEqual(input, result)
        }
    }

    /// Tests that tapping backspace deletes one digit.
    /// Also tests that tapping backspace when the input is already empty does nothing
    func testBackspaceTap() {
        let input = "1234"
        let viewModel = DigitPadViewModel()
        viewModel.reset(to: input)
        
        var expected = input
        for _ in input.count + 1 {
            viewModel.backspaceButtonViewModel.tap()
            expected = String(expected.dropLast())
            XCTAssertEqual(viewModel.value, expected)
        }
    }
    
    /// Tests tapping on custom button
    func testCustomButtonTap() throws {
        let customButtonViewModel = DigitPadButtonViewModel.empty
        let viewModel = DigitPadViewModel(customButtonViewModel: customButtonViewModel)
        var isTapped = false
        
        viewModel.customButtonTapObservable.bind {
            isTapped = true
        }.disposed(by: bag)
        
        customButtonViewModel.tap()
        XCTAssert(isTapped)
    }
}
