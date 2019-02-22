//
//  BitcoinHDAssetAccount.swift
//  BitcoinKit
//
//  Created by kevinwu on 2/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinHDAssetAccount: HDAddressAssetAccount {

    // MARK: - HDAddressAssetAccount

    public typealias Address = BitcoinAssetAddress

    public let xpub: String

    public var currentAddress: Address {
        return BitcoinAssetAddress(
            isImported: false,
            publicKey: ""
        )
    }

    public var currentReceiveIndex: Int

    // MARK: - AssetAccount

    public var accountAddress: String {
        return currentAddress.publicKey
    }

    public var name: String

    public var description: String

    public var walletIndex: Int
}
