//
//  AssetAccountDetails.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol AssetAccountDetails {
    associatedtype Account: AssetAccount
    
    // Decorated account
    var account: Account { get }
    var balance: CryptoValue { get }
}
