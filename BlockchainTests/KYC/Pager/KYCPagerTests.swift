//
//  KYCPagerTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class KYCPagerTests: XCTestCase {

    private var pager: KYCPagerAPI!
    private var dataRepository: MockBlockchainDataRepository!

    override func setUp() {
        super.setUp()
        dataRepository = MockBlockchainDataRepository()
        pager = KYCPager(dataRepository: dataRepository, tier: .tier1)
    }

    /// Tests that next page is not null if the backend has decided that the user
    /// should go through the next tier via `user.tiers.next`
    func testHasNextPageOnNextTier() {
        let exp = expectation(description: "More information controller is presented if next tier is set")
        let lastPage = KYCPageType.lastPage(forTier: .tier1)
        let tiers = NabuUserTiers(
            current: KYCTier.tier0,
            selected: KYCTier.tier1,
            next: KYCTier.tier2
        )
        dataRepository.mockNabuUser = createTestNabuUser(tiers: tiers)
        _ = pager.nextPage(from: lastPage, payload: nil)
            .subscribe(onSuccess: { page in
                guard case .tier1ForcedTier2 = page else { return }
                exp.fulfill()
            })
        wait(for: [exp], timeout: 0.1)
    }

    /// Tests that next page is null if the user is on the last page of a tier and
    /// the backend has decided that the user should not go through the next tier
    func testHasNoNextPageOnNextTier() {
        let exp = expectation(description: "onCompleted is called when no next tier")
        let lastPage = KYCPageType.lastPage(forTier: .tier1)
        dataRepository.mockNabuUser = createTestNabuUser()
        _ = pager.nextPage(from: lastPage, payload: nil)
            .subscribe(onCompleted: {
                exp.fulfill()
            })
        wait(for: [exp], timeout: 0.1)
    }

    private func createTestNabuUser(tiers: NabuUserTiers? = nil) -> NabuUser {
        return NabuUser(
            personalDetails: PersonalDetails(id: "id", first: "John", last: "Smithy", birthday: nil),
            address: nil,
            email: Email(address: "email@test.com", verified: false),
            mobile: nil,
            status: .none,
            state: .active,
            tags: nil,
            tiers: tiers
        )
    }
}
