//
//  EthereumWalletAccount.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct EthereumWalletAccount: WalletAccount, Codable {
    public let index: Int
    public let publicKey: String
    public var label: String?
    public var archived: Bool
}
