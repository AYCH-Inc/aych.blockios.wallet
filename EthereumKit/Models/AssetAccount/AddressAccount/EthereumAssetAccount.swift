//
//  EthereumAssetAccount.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct EthereumAssetAccount: AssetAccount {
    public var walletIndex: Int

    public let accountAddress: String

    public var name: String

    public var description: String
}
