//
//  BitcoinWalletAccount.swift
//  BitcoinKit
//
//  Created by kevinwu on 2/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinWalletAccount: WalletAccount, Codable {
    public let index: Int
    public let publicKey: String
    public var label: String?
    public var archived: Bool
}
