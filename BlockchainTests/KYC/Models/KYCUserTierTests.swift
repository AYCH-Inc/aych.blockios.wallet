//
//  KYCUserTierTests.swift
//  BlockchainTests
//
//  Created by AlexM on 12/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class KYCUserTierTests: XCTestCase {
    func testLockedState() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .none)
        let userTier2 = KYCUserTier(tier: .tier2, state: .none)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        XCTAssertNil(badgeModel)
    }
    
    func testTier1Pending() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .pending)
        let userTier2 = KYCUserTier(tier: .tier2, state: .none)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier1.name + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testTier1Verified() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .verified)
        let userTier2 = KYCUserTier(tier: .tier2, state: .none)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier1.name + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testTier1PendingTier2Pending() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .pending)
        let userTier2 = KYCUserTier(tier: .tier2, state: .pending)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testTier1VerifiedTier2Pending() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .verified)
        let userTier2 = KYCUserTier(tier: .tier2, state: .pending)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testTier1FailedTier2Pending() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .rejected)
        let userTier2 = KYCUserTier(tier: .tier2, state: .pending)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testTier2Verified() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .none)
        let userTier2 = KYCUserTier(tier: .tier2, state: .verified)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testTier1PendingTier2Verified() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .pending)
        let userTier2 = KYCUserTier(tier: .tier2, state: .verified)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func testVerifiedState() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .verified)
        let userTier2 = KYCUserTier(tier: .tier2, state: .verified)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func tier2Pending() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .none)
        let userTier2 = KYCUserTier(tier: .tier2, state: .pending)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier2.name + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
    
    func tier1Rejected() {
        let userTier1 = KYCUserTier(tier: .tier1, state: .rejected)
        let userTier2 = KYCUserTier(tier: .tier2, state: .none)
        let response = KYCUserTiersResponse(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = userTier1.name + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
}

extension KYCUserTier {
    fileprivate static let tier1Rejected = KYCUserTier(tier: .tier1, state: .rejected)
    fileprivate static let tier2Rejected = KYCUserTier(tier: .tier2, state: .rejected)
    
    fileprivate static let tier1Approved = KYCUserTier(tier: .tier1, state: .verified)
    fileprivate static let tier2Approved = KYCUserTier(tier: .tier2, state: .verified)
    
    fileprivate static let tier1Pending = KYCUserTier(tier: .tier1, state: .pending)
    fileprivate static let tier2Pending = KYCUserTier(tier: .tier2, state: .pending)
    
    fileprivate static let tier1None = KYCUserTier(tier: .tier1, state: .none)
    fileprivate static let tier2None = KYCUserTier(tier: .tier2, state: .none)
}
