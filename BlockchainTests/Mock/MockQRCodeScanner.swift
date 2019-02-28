//
//  MockQRCodeScanner.swift
//  BlockchainTests
//
//  Created by Jack on 19/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockParser: QRCodeScannerParsing {
    
    enum MockParserError: Error {
        case unknown
    }
    
    struct Model: Equatable {
        let value: String
    }
    
    var _parse: (NewResult<String, QRScannerError>) -> NewResult<Model, MockParserError> = {
        result in
        
        guard case .success(let scannedString) = result else {
            return .failure(.unknown)
        }
        return .success(Model(value: scannedString))
    }
    func parse(scanResult: NewResult<String, QRScannerError>, completion: ((NewResult<Model, MockParserError>) -> Void)?) {
        completion?(_parse(scanResult))
    }
}

class MockScanner: QRCodeScannerProtocol {
    var videoPreviewLayer: CALayer = CALayer()
    
    var delegate: QRCodeScannerDelegate? = nil
    
    var startReadingQRCodeCalled: () -> Void = { }
    var startReadingQRCodeCallCount: Int = 0
    func startReadingQRCode() {
        startReadingQRCodeCallCount += 1
        startReadingQRCodeCalled()
    }
    
    var stopReadingQRCodeCalled: () -> Void = { }
    var stopReadingQRCodeCallCount: Int = 0
    func stopReadingQRCode(complete: (() -> Void)?) {
        stopReadingQRCodeCallCount += 1
        stopReadingQRCodeCalled()
        complete?()
    }
}

class MockScannerTextViewModel: QRCodeScannerTextViewModel {
    var loadingText: String? = "loadingText"
    var headerText: String = "headerText"
}
