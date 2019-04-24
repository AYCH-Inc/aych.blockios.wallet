//
//  PaxToken.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import EthereumKit

public struct PaxToken: ERC20Token {
    public static let assetType: CryptoCurrency = .pax
    public static let contractAddress: String = "0x8e870d67f660d95d5be530380d0ec0bd388289e1"
}
