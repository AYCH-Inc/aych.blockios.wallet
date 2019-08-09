//
//  QRCodeGeneratorTests.swift
//  BlockchainTests
//
//  Created by Jack on 02/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import BitcoinKit
@testable import PlatformKit
@testable import PlatformUIKit
@testable import Blockchain

class QRCodeWrapperMock: QRCodeWrapperAPI {
    var lastMetadata: CryptoAssetQRMetadata?
    var qrCodeFromMetadataValue: QRCodeAPI?
    func qrCode(from metadata: CryptoAssetQRMetadata) -> QRCodeAPI? {
        lastMetadata = metadata
        return qrCodeFromMetadataValue
    }
    
    var lastString: String?
    var qrCodeFromStringValue: QRCodeAPI?
    func qrCode(from string: String) -> QRCodeAPI? {
        lastString = string
        return qrCodeFromStringValue
    }
}

class QRCodeGeneratorTests: XCTestCase {
    
    var subject: QRCodeGenerator!
    var qrCodeWrapper: QRCodeWrapperMock!

    override func setUp() {
        super.setUp()
        
        qrCodeWrapper = QRCodeWrapperMock()
        subject = QRCodeGenerator(qrCodeWrapper: qrCodeWrapper)
    }

    override func tearDown() {
        subject = nil
        qrCodeWrapper = nil
        
        super.tearDown()
    }

    func test_qrcode_from_string() {
        let testString = "xpub<ADDRESS>"
        qrCodeWrapper.qrCodeFromStringValue = QRCode(string: testString)
        let image = subject.createQRImage(fromString: testString)
        XCTAssertNotNil(image)
        XCTAssertEqual(qrCodeWrapper.lastString, testString)
    }
    
    func test_qrcode_from_address() {
        let address = "<ADDRESS>"
        let amount = "12.34"
        let asset: LegacyAssetType = .bitcoin
        let metadata = BitcoinQRMetadata(address: address, amount: amount, includeScheme: false)
        qrCodeWrapper.qrCodeFromMetadataValue = QRCode(metadata: metadata)
        
        let image = subject.qrImage(
            fromAddress: address,
            amount: amount,
            asset: asset,
            includeScheme: false
        )
        XCTAssertNotNil(image)
        XCTAssertNotNil(qrCodeWrapper.lastMetadata)
        XCTAssertEqual(qrCodeWrapper.lastMetadata?.absoluteString, metadata.absoluteString)
        XCTAssertEqual(qrCodeWrapper.lastMetadata?.address, metadata.address)
        XCTAssertEqual(qrCodeWrapper.lastMetadata?.amount, metadata.amount)
        XCTAssertEqual(qrCodeWrapper.lastMetadata?.includeScheme, metadata.includeScheme)
    }
}
