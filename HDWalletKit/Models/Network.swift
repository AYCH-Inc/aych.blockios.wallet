//
//  Network.swift
//  HDWalletKit
//
//  Created by Jack on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally

public protocol CoinType {
    static var coinType: UInt32 { get }
}

// TODO:
// * Move to BitcoinKit
// * Is this the right design???
public struct Bitcoin: CoinType {
    public static let coinType: UInt32 = 0
}

// TODO
// * For now `CoinType` is not supported by LibWally-Swift,
public enum Network {
    case main(CoinType.Type)
    case test
    
    var libWallyNetwork: LibWally.Network {
        switch self {
        case .main:
            return LibWally.Network.mainnet
        case .test:
            return LibWally.Network.testnet
        }
    }
}
