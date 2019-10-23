//
//  StellarAirdropRouterTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit
import XCTest
@testable import Blockchain

class StellarAirdropRouterTests: XCTestCase {

    private var mockAppSettings: MockBlockchainSettingsApp!
    private var mockStellarBridge: MockStellarBridge!
    private var mockDataRepo: MockBlockchainDataRepository!
    private var router: StellarAirdropRouter!

    override func setUp() {
        super.setUp()
        mockAppSettings = MockBlockchainSettingsApp()
        mockDataRepo = MockBlockchainDataRepository()
        mockStellarBridge = MockStellarBridge()
        
        router = StellarAirdropRouter(
            appSettings: mockAppSettings,
            repository: mockDataRepo,
            stellarWalletAccountRepository: StellarWalletAccountRepository(with: mockStellarBridge)
        )
    }

    func testRoutesIfTappedOnDeepLink() {
        mockAppSettings.mockDidTapOnAirdropDeepLink = true
        mockStellarBridge.accounts = [
            StellarWalletAccount(index: 0, publicKey: "public key", label: "label", archived: false)
        ]
        mockDataRepo.mockNabuUser = NabuUser(
            personalDetails: nil,
            address: nil,
            email: Email(address: "test", verified: false),
            mobile: nil,
            status: KYCAccountStatus.none,
            state: NabuUser.UserState.none,
            tags: Tags(),
            tiers: nil,
            needsDocumentResubmission: nil
        )
        XCTAssertTrue(router.routeIfNeeded())
    }

    func testDoesNotRouteIfDidntTapOnDeepLink() {
        mockAppSettings.mockDidTapOnAirdropDeepLink = false
        XCTAssertFalse(router.routeIfNeeded())
    }
}
