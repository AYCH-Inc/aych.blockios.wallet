//
//  BalanceDetailsResponse.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import PlatformKit

/// TODO: `BalanceDetails` can likely be re-used for other asset types for native
/// balance fetching.
struct BalanceDetailsResponse: Decodable {
    let balance: String
    let nonce: Int
    
    enum CodingKeys: String, CodingKey {
        case address
        case balance
        case nonce
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        balance = try values.decode(String.self, forKey: .balance)
        nonce = try values.decode(Int.self, forKey: .nonce)
    }
}

extension BalanceDetailsResponse {
    var cryptoValue: CryptoValue {
        return CryptoValue.createFromMinorValue(BigInt(balance) ?? BigInt(0), assetType: .ethereum)
    }
}
