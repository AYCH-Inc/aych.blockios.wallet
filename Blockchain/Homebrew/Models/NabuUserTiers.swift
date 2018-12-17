//
//  NabuUserTiers.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct NabuUserTiers: Decodable {
    let current: KYCTier
    let selected: KYCTier
    let next: KYCTier

    enum CodingKeys: String, CodingKey {
        case current
        case selected
        case next
    }

    init(current: KYCTier, selected: KYCTier, next: KYCTier) {
        self.current = current
        self.selected = selected
        self.next = next
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.current = KYCTier(rawValue: try values.decodeIfPresent(Int.self, forKey: .current) ?? 0) ?? .tier0
        self.selected = KYCTier(rawValue: try values.decodeIfPresent(Int.self, forKey: .selected) ?? 0) ?? .tier0
        self.next = KYCTier(rawValue: try values.decodeIfPresent(Int.self, forKey: .next) ?? 0) ?? .tier0
    }
}
