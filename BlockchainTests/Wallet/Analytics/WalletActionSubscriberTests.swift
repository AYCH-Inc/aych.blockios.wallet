//
//  WalletActionSubscriberTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 11/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

@testable import Blockchain

class WalletActionSubscriberTests: XCTestCase {

    private var mockAppSettings: MockBlockchainSettingsApp!
    private var eventBus: WalletActionEventBus!
    private var mockWalletSettings: MockWalletSettingsService!
    private var subscriber: WalletActionSubscriber!

    override func setUp() {
        super.setUp()
        eventBus = WalletActionEventBus()
        mockAppSettings = MockBlockchainSettingsApp()
        mockAppSettings.guid = "wallet_guid"
        mockAppSettings.sharedKey = "wallet_sharedKey"
        mockWalletSettings = MockWalletSettingsService()
        subscriber = WalletActionSubscriber(
            appSettings: mockAppSettings,
            bus: eventBus,
            walletSettings: mockWalletSettings
        )
    }

    func testTxUpdatedOnSendCrypto() {
        mockWalletSettings.didCallUpdateLastTxTime = expectation(description: "last-tx-time updated on send crypto")
        subscriber.subscribe()
        eventBus.publish(action: .sendCrypto)
        waitForExpectations(timeout: 0.1)
    }

    func testTxUpdatedOnBuyCryptoWithFiat() {
        mockWalletSettings.didCallUpdateLastTxTime = expectation(description: "last-tx-time updated on buy crypto")
        subscriber.subscribe()
        eventBus.publish(action: .buyCryptoWithFiat)
        waitForExpectations(timeout: 0.1)
    }

    func testTxUpdatedOnSellCryptoToFiat() {
        mockWalletSettings.didCallUpdateLastTxTime = expectation(description: "last-tx-time updated on sell crypto")
        subscriber.subscribe()
        eventBus.publish(action: .sellCryptoToFiat)
        waitForExpectations(timeout: 0.1)
    }
}
