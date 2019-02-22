//
//  StellarAssetAccount.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct StellarAssetAccount: SingleAddressAssetAccount {
    public var walletIndex: Int

    public typealias Address = StellarAssetAddress
    
    public var address: StellarAssetAddress
    public var accountAddress: String
    public var name: String
    public var description: String
    public var sequence: Int
    public var subentryCount: Int
    
    public init(accountAddress: String,
                name: String,
                description: String,
                sequence: Int,
                subentryCount: Int) {
        self.walletIndex = 0
        self.accountAddress = accountAddress
        self.name = name
        self.description = description
        self.sequence = sequence
        self.subentryCount = subentryCount
        self.address = StellarAssetAddress(publicKey: accountAddress)
    }
}
