//
//  BitcoinWalletBridgeAPI.swift
//  BitcoinKit
//
//  Created by kevinwu on 2/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol BitcoinWalletBridgeAPI: class {
    /// If an imported address or HD account is active, it means that it is not archived.
    
    // MARK: - Wallet Account
    
    var defaultWallet: Single<BitcoinWalletAccount> { get }

    var wallets: Single<[BitcoinWalletAccount]> { get }
}
