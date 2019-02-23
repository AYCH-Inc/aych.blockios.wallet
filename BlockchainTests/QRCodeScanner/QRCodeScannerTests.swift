//
//  QRCodeScannerTests.swift
//  BlockchainTests
//
//  Created by Jack on 17/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class QRCodeScannerTests: XCTestCase {
    
    var subject: QRCodeScanner!
    var deviceInputMock: DeviceInputMock!
    var captureSession: CaptureSessionMock!
    var captureMetadataOutput: CaptureMetadataOutputMock!
    var delegate: QRCodeScannerDelegateMock!

    override func setUp() {
    }

    override func tearDown() {
    }
    
    func test_setup() {
        let inputAddedExpectaion = expectation(description: "Input added")
        let outputAddedExpectaion = expectation(description: "Output added")
        let metadataObjectsAddedExpectaion = expectation(description: "metadata objects added")
        
        deviceInputMock = DeviceInputMock()
        captureSession = CaptureSessionMock()
        captureMetadataOutput = CaptureMetadataOutputMock()
        delegate = QRCodeScannerDelegateMock()
        
        XCTAssertEqual(captureSession.inputsAdded.count, 0)
        captureSession.addInputCallback = { _ in
            XCTAssertEqual(self.captureSession.inputsAdded.count, 1)
            inputAddedExpectaion.fulfill()
        }
        
        XCTAssertEqual(captureSession.outputsAdded.count, 0)
        captureSession.addOutputCallback = { _ in
            XCTAssertEqual(self.captureSession.outputsAdded.count, 1)
            outputAddedExpectaion.fulfill()
        }
        
        XCTAssertEqual(captureMetadataOutput.metadataObjects.count, 0)
        captureMetadataOutput.setMetadataObjectsDelegateCalled = { _ in
            XCTAssertEqual(self.captureMetadataOutput.metadataObjects.count, 1)
            metadataObjectsAddedExpectaion.fulfill()
        }
        
        subject = QRCodeScanner(
            deviceInput: deviceInputMock,
            captureSession: captureSession,
            captureMetadataOutputBuilder: { self.captureMetadataOutput }
        )
        subject.delegate = delegate
        
        waitForExpectations(timeout: 5)
    }
    
    func test_startReadingQRCode() {
        let startRunningCalled = expectation(description: "startRunning called")
        let didStartScanningCalled = expectation(description: "didStartScanning called")
        
        deviceInputMock = DeviceInputMock()
        captureSession = CaptureSessionMock()
        captureMetadataOutput = CaptureMetadataOutputMock()
        delegate = QRCodeScannerDelegateMock()
        
        captureSession.startRunningCallback = {
            startRunningCalled.fulfill()
        }
        
        captureSession.stopRunningCallback = {
            XCTFail("Stop running shouldn't be called")
        }
        
        XCTAssertEqual(delegate.didStartScanningCallCount, 0)
        XCTAssertEqual(captureSession.startRunningCallCount, 0)
        
        delegate.didStartScanningCalled = {
            XCTAssertEqual(self.delegate.didStartScanningCallCount, 1)
            XCTAssertEqual(self.captureSession.startRunningCallCount, 1)
            
            didStartScanningCalled.fulfill()
        }
        
        delegate.didStopScanningCalled = {
            XCTFail("Stop scanning shouldn't be called")
        }
        
        subject = QRCodeScanner(
            deviceInput: deviceInputMock,
            captureSession: captureSession,
            captureMetadataOutputBuilder: { self.captureMetadataOutput }
        )
        subject.delegate = delegate
        
        subject.startReadingQRCode()
        
        waitForExpectations(timeout: 5)
    }

    func test_stopReadingQRCode() {
        let stopRunningCalled = expectation(description: "stopRunning called")
        let didStopScanningCalled = expectation(description: "didStopScanning called")
        
        deviceInputMock = DeviceInputMock()
        captureSession = CaptureSessionMock()
        captureMetadataOutput = CaptureMetadataOutputMock()
        delegate = QRCodeScannerDelegateMock()
        
        captureSession.startRunningCallback = {
            XCTFail("Start running shouldn't be called")
        }
        
        captureSession.stopRunningCallback = {
             stopRunningCalled.fulfill()
        }
        
        XCTAssertEqual(delegate.didStopScanningCallCount, 0)
        XCTAssertEqual(captureSession.stopRunningCallCount, 0)
        
        delegate.didStartScanningCalled = {
            XCTFail("Start scanning shouldn't be called")
        }
        
        delegate.didStopScanningCalled = {
            XCTAssertEqual(self.delegate.didStopScanningCallCount, 1)
            XCTAssertEqual(self.captureSession.stopRunningCallCount, 1)
            
            didStopScanningCalled.fulfill()
        }
        
        subject = QRCodeScanner(
            deviceInput: deviceInputMock,
            captureSession: captureSession,
            captureMetadataOutputBuilder: { self.captureMetadataOutput }
        )
        subject.delegate = delegate
        
        subject.stopReadingQRCode()
        
        waitForExpectations(timeout: 5)
    }
}
