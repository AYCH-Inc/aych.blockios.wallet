//
//  KYCPageTypeTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 12/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class KYCPageTypeTests: XCTestCase {
    
    /// A `KYCUserTiersResponse` where the user has been verified for tier1
    /// and their tier2 status is pending.
    private let pendingTier2Response = KYCUserTiersResponse(
        tiers: [
            KYCUserTier(tier: .tier1, state: .verified),
            KYCUserTier(tier: .tier2, state: .pending)
        ]
    )
    
    /// A `KYCUserTiersResponse` where the user has not been verified or
    /// applied to either tier1 or tier2.
    private let noTiersResponse = KYCUserTiersResponse(
        tiers: [
            KYCUserTier(tier: .tier1, state: .none),
            KYCUserTier(tier: .tier2, state: .none)
        ]
    )

    func testStartingPage() {
        XCTAssertEqual(
            KYCPageType.enterEmail,
            KYCPageType.startingPage(forUser: createNabuUser(), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.startingPage(forUser: createNabuUser(isEmailVerified: true), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.enterPhone,
            KYCPageType.startingPage(forUser: createNabuUser(isEmailVerified: true, hasAddress: true), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.verifyIdentity,
            KYCPageType.startingPage(forUser: createNabuUser(isMobileVerified: true, isEmailVerified: true, hasAddress: true), tiersResponse: noTiersResponse)
        )
    }

    func testNextPageTier1() {
        XCTAssertEqual(
            KYCPageType.confirmEmail,
            KYCPageType.enterEmail.nextPage(forTier: .tier1, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.confirmEmail.nextPage(forTier: .tier1, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.country.nextPage(forTier: .tier1, user: nil, country: createKycCountry(hasStates: true), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.country.nextPage(forTier: .tier1, user: nil, country: createKycCountry(hasStates: false), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.states.nextPage(forTier: .tier1, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.profile.nextPage(forTier: .tier1, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertNil(KYCPageType.address.nextPage(forTier: .tier1, user: nil, country: nil, tiersResponse: pendingTier2Response))
    }

    func testNextPageTier2() {
        XCTAssertEqual(
            KYCPageType.confirmEmail,
            KYCPageType.enterEmail.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.confirmEmail.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.country.nextPage(forTier: .tier2, user: nil, country: createKycCountry(hasStates: true), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.country.nextPage(forTier: .tier2, user: nil, country: createKycCountry(hasStates: false), tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.states.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.profile.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.enterPhone,
            KYCPageType.address.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.verifyIdentity,
            KYCPageType.address.nextPage(forTier: .tier2, user: createNabuUser(isMobileVerified: true), country: nil, tiersResponse: noTiersResponse)
        )
        XCTAssertEqual(
            KYCPageType.confirmPhone,
            KYCPageType.enterPhone.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.verifyIdentity,
            KYCPageType.confirmPhone.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
        XCTAssertEqual(
            KYCPageType.accountStatus,
            KYCPageType.verifyIdentity.nextPage(forTier: .tier2, user: nil, country: nil, tiersResponse: pendingTier2Response)
        )
    }

    private func createKycCountry(hasStates: Bool = false) -> KYCCountry {
        let states = hasStates ? ["state"] : []
        return KYCCountry(code: "test", name: "Test Country", regions: [], scopes: nil, states: states)
    }

    private func createNabuUser(isMobileVerified: Bool = false, isEmailVerified: Bool = false, hasAddress: Bool = false) -> NabuUser {
        let mobile = Mobile(phone: "1234567890", verified: isMobileVerified)
        var address: UserAddress? = nil
        if hasAddress {
            address = UserAddress(
                lineOne: "Address",
                lineTwo: "Address 2",
                postalCode: "123",
                city: "City",
                state: "CA",
                countryCode: "US"
            )
        }
        return NabuUser(
            personalDetails: nil,
            address: address,
            email: Email(address: "test", verified: isEmailVerified),
            mobile: mobile,
            status: KYCAccountStatus.none,
            state: NabuUser.UserState.none,
            tags: Tags(),
            tiers: nil,
            needsDocumentResubmission: nil
        )
    }
}
