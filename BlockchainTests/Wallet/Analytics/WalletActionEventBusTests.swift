//
//  WalletActionEventBusTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 11/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import XCTest

class WalletActionEventBusTests: XCTestCase {

    /// Tests that a WalletAction is published and propagated through the event bus
    func testWalletActionIsPublished() {
        let exp = expectation(description: "Subscriber receives event emitted from event bus.")
        let eventBus = WalletActionEventBus()
        let action = WalletAction.receiveCrypto
        _ = eventBus.events.subscribe(onNext: {
            if action == $0.action {
                exp.fulfill()
            }
        })
        eventBus.publish(action: action)
        wait(for: [exp], timeout: 0.1)
    }
}
