//
//  HDAddressAssetAccount.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The Hierarchical Deterministic (HD) key creation and transfer protocol (BIP32),
/// which allows creating child keys from parent keys in a hierarchy.
/// Wallets using the HD protocol are called HD wallets.
public protocol HDAddressAssetAccount: MultiAddressAssetAccount {
    associatedtype Address: AssetAddress
    
    // The xpub address where addresses are derived from
    var xpub: String { get }

    /** Derived address from the current receive index. This is expected to change to a new address after first receiving funds.
     */
    var currentAddress: Address { get }
}
