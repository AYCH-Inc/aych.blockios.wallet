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

private class MockRegistrationService: StellarAirdropRegistrationAPI {
    
    var didCallRegisterExpectation: XCTestExpectation?

    func registerForCampaign(xlmAccount: StellarWalletAccount, nabuUser: NabuUser) -> Single<StellarRegisterCampaignResponse> {
        return Single.create(subscribe: { _ -> Disposable in
            self.didCallRegisterExpectation?.fulfill()
            return Disposables.create()
        })
    }
}

class StellarAirdropRouterTests: XCTestCase {

    private var mockAppSettings: MockBlockchainSettingsApp!
    private var mockRegistration: MockRegistrationService!
    private var mockStellarBridge: MockStellarBridge!
    private var mockDataRepo: MockBlockchainDataRepository!
    private var router: StellarAirdropRouter!

    override func setUp() {
        super.setUp()
        mockAppSettings = MockBlockchainSettingsApp()
        mockRegistration = MockRegistrationService()
        mockDataRepo = MockBlockchainDataRepository()
        mockStellarBridge = MockStellarBridge()
        
        router = StellarAirdropRouter(
            appSettings: mockAppSettings,
            repository: mockDataRepo,
            stellarWalletAccountRepository: StellarWalletAccountRepository(with: mockStellarBridge),
            registrationService: mockRegistration
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
