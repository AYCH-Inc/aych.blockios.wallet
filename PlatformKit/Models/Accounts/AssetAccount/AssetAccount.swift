//
//  AssetAccount.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol AssetAccount {
    // `accountAddress` can be an xpub,
    // eth address, public key, etc.
    var accountAddress: String { get }
    var name: String { get }
    
    /// TODO: Can this be nil for some accounts? What is the expected
    /// value of this? 
    var description: String { get }

    var walletIndex: Int { get }
}
