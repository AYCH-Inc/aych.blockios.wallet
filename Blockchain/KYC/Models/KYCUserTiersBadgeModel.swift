//
//  KYCUserTiersBadgeModel.swift
//  Blockchain
//
//  Created by kevinwu on 12/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCUserTiersBadgeModel {
    let color: UIColor
    let text: String

    init?(response: KYCUserTiersResponse) {
        let tiers = response.userTiers
        
        /// Note that we are only accounting for `KYCTier1` and `KYCTier2`.
        /// Currently we aren't supporting other tiers outside of that.
        /// If we add additional types to `KYCTier` we'll want to update this.
        guard tiers.count > 0 else { return nil }
        guard let tier1 = tiers.filter({ $0.tier == .tier1 }).first else { return nil }
        guard let tier2 = tiers.filter({ $0.tier == .tier2 }).first else { return nil }
        let locked = tier1.state == .none && tier2.state == .none
        guard locked == false else { return nil }
        
        let currentTier = tier2.state != .none ? tier2 : tier1
        color = KYCUserTiersBadgeModel.badgeColor(for: currentTier)
        text = KYCUserTiersBadgeModel.badgeText(for: currentTier)
    }

    private static func badgeColor(for tier: KYCUserTier) -> UIColor {
        switch tier.state {
        case .none:
            return .unverified
        case .rejected:
            return .unverified
        case .pending:
            return .pending
        case .verified:
            return .verified
        }
    }

    private static func badgeText(for tier: KYCUserTier) -> String {
        switch tier.state {
        case .none:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountUnverifiedBadge)
        case .rejected:
            return LocalizationConstants.KYC.verificationFailedBadge
        case .pending:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountInReviewBadge)
        case .verified:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountApprovedBadge)
        }
    }

    private static func badgeString(tier: KYCUserTier, description: String) -> String {
        return tier.name + " - " + description
    }
}
