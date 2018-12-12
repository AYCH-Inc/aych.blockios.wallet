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

    init(userTiers: KYCUserTiersResponse) {
        guard let tierToDisplay = KYCUserTier.latestTier(tiers: userTiers.userTiers) else {
            text = LocalizationConstants.Errors.error
            color = .unverified
            return
        }
        color = KYCUserTiersBadgeModel.badgeColor(for: tierToDisplay)
        text = KYCUserTiersBadgeModel.badgeText(for: tierToDisplay)
    }

    private static func badgeColor(for tier: KYCUserTier) -> UIColor {
        switch tier.state {
        case .none: return .unverified
        case .rejected: return .unverified
        case .pending: return .pending
        case .verified: return .verified
        }
    }

    private static func badgeText(for tier: KYCUserTier) -> String {
        switch tier.state {
        case .none:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountUnverifiedBadge)
        case .rejected:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountUnverifiedBadge)
        case .pending:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountInReviewBadge)
        case .verified:
            return badgeString(tier: tier, description: LocalizationConstants.KYC.accountVerifiedBadge)
        }
    }

    private static func badgeString(tier: KYCUserTier, description: String) -> String {
        return tier.name + " - " + description
    }
}
