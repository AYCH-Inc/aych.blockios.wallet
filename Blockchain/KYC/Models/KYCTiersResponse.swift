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
    
    init(tiers: [KYCUserTier]) {
        self.userTiers = tiers
    }
}

extension KYCUserTiersResponse {
    
    var tier2AccountStatus: KYCAccountStatus {
        guard let tier2 = userTiers.first(where: { $0.tier == .tier2 }) else { return .none }
        switch tier2.state {
        case .none:
            return .none
        case .rejected:
            return .failed
        case .pending:
            return .pending
        case .verified:
            return .approved
        }
    }
    
    var tier1AccountStatus: KYCAccountStatus {
        guard let tier1 = userTiers.first(where: { $0.tier == .tier1 }) else { return .none }
        switch tier1.state {
        case .none:
            return .none
        case .rejected:
            return .failed
        case .pending:
            return .pending
        case .verified:
            return .approved
        }
    }
    
    /// Returns `true` if the user is not tier2 verified, rejected or pending
    var canCompleteTier2: Bool {
        return userTiers.contains(where: {
            return $0.tier == .tier2 &&
                ($0.state != .pending && $0.state != .rejected && $0.state != .verified)
        })
    }

    var isTier2Pending: Bool {
        return userTiers.contains(where: {
            return $0.tier == .tier2 && $0.state == .pending
        })
    }
    
    var isTier2Verified: Bool {
        return userTiers.contains(where: {
            return $0.tier == .tier2 && $0.state == .verified
        })
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
        switch tier {
        case .tier0: name = LocalizationConstants.KYC.tierZeroVerification
        case .tier1: name = LocalizationConstants.KYC.tierOneVerification
        case .tier2: name = LocalizationConstants.KYC.tierTwoVerification
        }
        state = try values.decode(KYCTierState.self, forKey: .state)
        limits = try values.decodeIfPresent(KYCUserTiersLimits.self, forKey: .limits)
    }
    
    /// MARK - Init - Convenience init for testing purposes
    init(tier: KYCTier, state: KYCTierState) {
        self.tier = tier
        self.state = state
        self.name = ""
        self.limits = nil
    }
}

extension KYCUserTier: Equatable {
    
    static func ==(lhs: KYCUserTier, rhs: KYCUserTier) -> Bool {
        return lhs.tier == rhs.tier &&
        lhs.state == rhs.state &&
        lhs.name == rhs.name &&
        lhs.limits == rhs.limits
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

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decode(String.self, forKey: .currency)
        let dailyRaw = try values.decodeIfPresent(String.self, forKey: .daily) ?? ""
        daily = Decimal(string: dailyRaw)
        let annualRaw = try values.decodeIfPresent(String.self, forKey: .annual) ?? ""
        annual = Decimal(string: annualRaw)
    }
}

extension KYCUserTiersLimits: Equatable {
    static func ==(lhs: KYCUserTiersLimits, rhs: KYCUserTiersLimits) -> Bool {
        return lhs.currency == rhs.currency &&
        lhs.daily == rhs.daily &&
        lhs.annual == rhs.annual
    }
}
