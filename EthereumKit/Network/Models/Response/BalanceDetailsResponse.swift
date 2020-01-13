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
public struct BalanceDetailsResponse {
    let balance: String
    let nonce: UInt64
}

extension BalanceDetailsResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case balance
        case nonce
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        balance = try values.decode(String.self, forKey: .balance)
        nonce = try values.decode(UInt64.self, forKey: .nonce)
    }
}

extension BalanceDetailsResponse {
    var cryptoValue: CryptoValue {
        return CryptoValue.createFromMinorValue(BigInt(balance) ?? BigInt(0), assetType: .ethereum)
    }
}
