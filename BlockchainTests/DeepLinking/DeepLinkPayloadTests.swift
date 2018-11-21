//
//  DeepLinkPayloadTests.swift
//  BlockchainTests
//
//  Created by Fred Cheng on 11/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest

class DeepLinkPayloadTests: XCTestCase {
    func testAirdropPayloadWithParams() {
        let url = URL(string: "https://login.blockchain.com/#/open/referral?campaign=sunriver&campaign_code=asdf-1234-efgh")!
        let payload = DeepLinkPayload.create(from: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload!.params["campaign_code"], "asdf-1234-efgh")
    }

    func testAirdropPayloadDecode() {
        let url = URL(string: "https://login.blockchain.com/#/open/referral?campaign=sunriver&campaign_email=email%2Bhi%40blah.com")!
        let payload = DeepLinkPayload.create(from: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload!.params["campaign_email"], "email+hi@blah.com")
    }
}
