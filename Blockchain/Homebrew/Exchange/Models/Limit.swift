//
//  Limit.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct Limit {
    let limit: Decimal
    let available: Decimal
    let used: Decimal
}

extension Limit: Decodable {
    enum CodingKeys: String, CodingKey {
        case limit
        case available
        case used
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        limit = try values.decodeIfPresent(String.self, forKey: .limit)?.toDecimal() ?? 0
        available = try values.decodeIfPresent(String.self, forKey: .available)?.toDecimal() ?? 0
        used = try values.decodeIfPresent(String.self, forKey: .used)?.toDecimal() ?? 0
    }
}
