//
//  QRCodeScannerViewModelTests.swift
//  BlockchainTests
//
//  Created by Jack on 18/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit
@testable import Blockchain

class QRCodeScannerViewModelTests: XCTestCase {
    
    var subject: QRCodeScannerViewModel<MockParser>!
    var parser: MockParser!
    var textViewModel: MockScannerTextViewModel!
    var scanner: MockScanner!
    var completion: ((NewResult<MockParser.T, MockParser.U>) -> Void)!

    override func setUp() {
        parser = MockParser()
        textViewModel = MockScannerTextViewModel()
        scanner = MockScanner()
        completion = { _ in }
        subject = QRCodeScannerViewModel(
            parser: parser,
            textViewModel: textViewModel,
            scanner: scanner,
            completed: completion
        )
    }

    override func tearDown() {
        parser = nil
        textViewModel = nil
        scanner = nil
        completion = nil
        subject = nil
    }
    
    func test_setup() {
        XCTAssertNotNil(subject.videoPreviewLayer)
        XCTAssertEqual(subject.loadingText, "loadingText")
        XCTAssertEqual(subject.headerText, "headerText")
    }
    
    func testCloseButtonPressed() {
        let expecationStopReadingQRCodeCalled = expectation(description: "stopReadingQRCode called")
        let expecationScanningStoppedCalled = expectation(description: "scanningStopped called")
        
        XCTAssertEqual(scanner.stopReadingQRCodeCallCount, 0)
        scanner.stopReadingQRCodeCalled = {
            XCTAssertEqual(self.scanner.stopReadingQRCodeCallCount, 1)
            expecationStopReadingQRCodeCalled.fulfill()
        }
        
        subject.scanningStopped = {
            expecationScanningStoppedCalled.fulfill()
        }
        
        subject.closeButtonPressed()
        scanner.delegate?.didStopScanning()
        
        waitForExpectations(timeout: 5)
    }
    
    func testStartReadingQRCode() {
        let expecationStopReadingQRCodeCalled = expectation(description: "stopReadingQRCode called")
        let expecationScanningStartedCalled = expectation(description: "scanningStarted called")
        
        XCTAssertEqual(scanner.startReadingQRCodeCallCount, 0)
        scanner.startReadingQRCodeCalled = {
            XCTAssertEqual(self.scanner.startReadingQRCodeCallCount, 1)
            expecationStopReadingQRCodeCalled.fulfill()
        }
        
        subject.scanningStarted = {
            expecationScanningStartedCalled.fulfill()
        }
        
        subject.startReadingQRCode()
        scanner.delegate?.didStartScanning()
        
        waitForExpectations(timeout: 5)
    }

    func testHandleDismissCompleted() {
        let expecationParseCalled = expectation(description: "parse called")
        let expecationScanCompleteCalled = expectation(description: "scanComplete called")
        
        subject = QRCodeScannerViewModel(
            parser: parser,
            textViewModel: textViewModel,
            scanner: scanner,
            completed: { result in
                guard case .success(let model) = result else {
                    XCTFail("the completion block is expected to be called with success")
                    return
                }
                XCTAssertEqual(model, MockParser.Model(value: "ScanValue"))
                expecationParseCalled.fulfill()
            }
        )
        
        subject.scanComplete = { result in
            guard case .success(let scannedString) = result else {
                XCTFail("the completion block is expected to be called with success")
                return
            }
            XCTAssertEqual(scannedString, "ScanValue")
            expecationScanCompleteCalled.fulfill()
        }
        
        scanner.delegate?.scanComplete(with: .success("ScanValue"))
        subject.handleDismissCompleted(with: .success("ScanValue"))
        
        waitForExpectations(timeout: 5)
    }
}
