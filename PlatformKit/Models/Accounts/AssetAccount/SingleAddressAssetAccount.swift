//
//  SingleAddressAssetAccount.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// An `AssetAccount` that only supports a single address (e.g. XLM)
public protocol SingleAddressAssetAccount: AssetAccount {
    associatedtype Address: AssetAddress
    var address: Address { get }
}
