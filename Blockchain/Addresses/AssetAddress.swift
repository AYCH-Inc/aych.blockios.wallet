//
//  AssetAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Blueprint for creating asset addresses.
@objc
public protocol AssetAddress {

    var address: String { get }

    var assetType: AssetType { get }

    var description: String { get }

    init(string: String)
}

extension AssetAddress {
    var depositAddress: DepositAddress {
        var addy = address
        if assetType == .bitcoinCash {
            addy.remove(prefix: "\(Constants.Schemes.bitcoinCash):")
        }
        return DepositAddress(type: assetType, address: addy)
    }
}
