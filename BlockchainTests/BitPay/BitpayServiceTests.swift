//
//  BitpayServiceTests.swift
//  Blockchain
//
//  Created by Will Hay on 8/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import Blockchain

class BitpayServicesTests: XCTestCase {
    
    func testBitPayServiceGetRawPaymentRequest() {
        let invoiceId = "4vzRL5oK5EuJ31cqLmkLp5"
        let mock = MockBitpayService()
        do {
            let requestResponse: ObjcCompatibleBitpayObject = try mock.getRawPaymentRequest(for: invoiceId).toBlocking().first()!
            XCTAssert(requestResponse.paymentUrl == ("https://bitpay.com/i/" + "\(invoiceId)"))
            XCTAssert(requestResponse.memo.contains(invoiceId))
        } catch {
            XCTFail("expected success, got \(error) instead")
        }
    }
    
}
