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
