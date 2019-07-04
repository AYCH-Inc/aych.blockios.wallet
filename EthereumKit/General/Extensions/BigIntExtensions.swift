//
//  BigIntExtensions.swift
//  EthereumKit
//
//  Created by Jack on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import web3swift

extension BigInt.Sign {
    static func from(string: String) -> BigInt.Sign {
        guard string.contains(Character("-")) else {
            return .plus
        }
        return .minus
    }
}

extension BigInt {
    public init?(string: String, unitDecimals: Int) {
        let sign = Sign.from(string: string)
        let trimmedString = string.replacingOccurrences(of: "-", with: "")
        guard let maginitude = BigUInt(string: trimmedString, unitDecimals: unitDecimals) else {
            return nil
        }
        self.init(sign: sign, magnitude: maginitude)
    }
}

extension BigUInt {
    public init?(string: String, unitDecimals: Int) {
        self.init(string, decimals: unitDecimals)
    }
}
