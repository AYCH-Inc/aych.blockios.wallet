//
//  KYCUserTiersResponse.swift
//  Blockchain
//
//  Created by kevinwu on 12/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCUserTiersResponse: Codable {
    let userTiers: [KYCUserTier]

    enum CodingKeys: String, CodingKey {
        case userTiers = "tiers"
    }
}

struct KYCUserTier: Codable {
    let tier: KYCTier
    let name: String
    let state: KYCTierState
    let limits: KYCUserTiersLimits?

    enum CodingKeys: String, CodingKey {
        case tier = "index"
        case name
        case state
        case limits
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let tierRawValue = try values.decode(Int.self, forKey: .tier)
        tier = KYCTier(rawValue: tierRawValue) ?? .tier0
        name = try values.decode(String.self, forKey: .name)
        state = try values.decode(KYCTierState.self, forKey: .state)
        limits = try values.decodeIfPresent(KYCUserTiersLimits.self, forKey: .limits)
    }
}

struct KYCUserTiersLimits: Codable {
    let currency: String
    let daily: Decimal?
    let annual: Decimal?

    enum CodingKeys: String, CodingKey {
        case currency
        case daily
        case annual
    }
}

extension KYCUserTier {
    static func latestTier(tiers: [KYCUserTier]) -> KYCUserTier? {
        let allUserTiers = tiers
        guard let firstTier = allUserTiers.first else {
            return nil
        }
        for (index, userTier) in allUserTiers.enumerated() {
            if userTier.state == .none && userTier.tier != firstTier.tier {
                return allUserTiers[index - 1] as KYCUserTier
            }
        }
        return nil
    }
}
