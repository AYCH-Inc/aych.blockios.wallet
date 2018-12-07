//
//  StellarAssetAccountDetails.swift
//  StellarKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import stellarsdk

public struct StellarAssetAccountDetails: AssetAccountDetails {
    public typealias Account = StellarAssetAccount
    
    public var account: StellarAssetAccount
    public var balance: CryptoValue
}

// MARK: Extension

public extension StellarAssetAccountDetails {
    static func unfunded(accountID: String) -> StellarAssetAccountDetails {
        // TODO: LocalizationConstants.Stellar.defaultLabelName
        let account = StellarAssetAccount(
            accountAddress: accountID,
            name: "My Stellar Wallet",
            description: "My Stellar Wallet",
            sequence: 0,
            subentryCount: 0
        )
        
        return StellarAssetAccountDetails(
            account: account,
            balance: CryptoValue.lumensFromMajor(int: 0)
        )
    }
}

// MARK: StellarSDK Convenience

public extension AccountResponse {
    
    public func toAssetAccountDetails() -> StellarAssetAccountDetails {
        let totalBalance = balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
        
        // TODO: LocalizationConstants.Stellar.defaultLabelName
        let account = StellarAssetAccount(
            accountAddress: accountId,
            name: "My Stellar Wallet",
            description: "My Stellar Wallet",
            sequence: Int(sequenceNumber),
            subentryCount: Int(subentryCount)
        )
        
        return StellarAssetAccountDetails(
            account: account,
            balance: CryptoValue.lumensFromMajor(decimal: totalBalance)
        )
    }
}
