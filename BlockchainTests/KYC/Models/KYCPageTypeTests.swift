//
//  KYCPageTypeTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 12/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class KYCPageTypeTests: XCTestCase {

    func testStartingPageTier1() {
        // TODO: add test to skip email verification step if user has already verified their email (waiting on backend)
        XCTAssertEqual(KYCPageType.enterEmail, KYCPageType.startingPage(forUser: createNabuUser(), tier: .tier1))
    }

    func testStartingPageTier2() {
        // TODO: add tests for starting page for tier2 but user is not tier1 approved (waiting on backend)
        XCTAssertEqual(KYCPageType.enterPhone, KYCPageType.startingPage(forUser: createNabuUser(), tier: .tier2))
        XCTAssertEqual(KYCPageType.verifyIdentity, KYCPageType.startingPage(forUser: createNabuUser(isMobileVerified: true), tier: .tier2))
    }

    func testNextPageTier1() {
        XCTAssertEqual(
            KYCPageType.confirmEmail,
            KYCPageType.enterEmail.nextPage(forTier: .tier1, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.confirmEmail.nextPage(forTier: .tier1, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.country.nextPage(forTier: .tier1, user: nil, country: createKycCountry(hasStates: true))
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.country.nextPage(forTier: .tier1, user: nil, country: createKycCountry(hasStates: false))
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.states.nextPage(forTier: .tier1, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.profile.nextPage(forTier: .tier1, user: nil, country: nil)
        )
        XCTAssertNil(KYCPageType.address.nextPage(forTier: .tier1, user: nil, country: nil))
    }

    func testNextPageTier2() {
        XCTAssertEqual(
            KYCPageType.confirmEmail,
            KYCPageType.enterEmail.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.confirmEmail.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.country.nextPage(forTier: .tier2, user: nil, country: createKycCountry(hasStates: true))
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.country.nextPage(forTier: .tier2, user: nil, country: createKycCountry(hasStates: false))
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.states.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.profile.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.enterPhone,
            KYCPageType.address.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.verifyIdentity,
            KYCPageType.address.nextPage(forTier: .tier2, user: createNabuUser(isMobileVerified: true), country: nil)
        )
        XCTAssertEqual(
            KYCPageType.confirmPhone,
            KYCPageType.enterPhone.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.verifyIdentity,
            KYCPageType.confirmPhone.nextPage(forTier: .tier2, user: nil, country: nil)
        )
        XCTAssertEqual(
            KYCPageType.applicationComplete,
            KYCPageType.verifyIdentity.nextPage(forTier: .tier2, user: nil, country: nil)
        )
    }

    private func createKycCountry(hasStates: Bool = false) -> KYCCountry {
        let states = hasStates ? ["state"] : []
        return KYCCountry(code: "test", name: "Test Country", regions: [], scopes: nil, states: states)
    }

    private func createNabuUser(isMobileVerified: Bool = false) -> NabuUser {
        let mobile = Mobile(phone: "1234567890", verified: isMobileVerified)
        return NabuUser(
            personalDetails: nil,
            address: nil,
            mobile: mobile,
            status: KYCAccountStatus.none,
            state: NabuUser.UserState.none,
            tags: Tags(sunriver: nil),
            tier: nil
        )
    }
}
