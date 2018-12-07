//
//  StellarWalletBridgeAPI.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `Wallet.m` needs to be injected into much of the `WalletRepository` type classes.
/// The reason is we still heavily rely on `My-Wallet-V3`. We don't want to bring this into
/// `PlatformKit` as a dependency. So, we have `Wallet.m` conform to protocols that we need
/// and inject it in as a dependency. Frequently we'll use the term `bridge` as a way of
/// describing this. 
public protocol StellarWalletBridgeAPI: class {
    typealias KeyPairSaveCompletion = (String?) -> Void
    
    func save(keyPair: StellarKeyPair, label: String, completion: @escaping KeyPairSaveCompletion)
    func stellarWallets() -> [StellarWalletAccount]
}
