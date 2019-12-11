//
//  Wallet+WalletProtocol.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// MARK: - AssetAddressSubscribing

extension Wallet: AssetAddressSubscribing {
    func subscribe(to address: String, asset: AssetType, addressType: AssetAddressType) {
        switch addressType {
        case .swipeToReceive:
            subscribe(toSwipeAddress: address, assetType: asset.legacy)
        case .standard:
            subscribe(toAddress: address, assetType: asset.legacy)
        }
    }
}

// MARK: - WalletProtocol

extension Wallet: WalletProtocol {
    
    @objc func encrypt(_ data: String, password: String) -> String {
        return self.encrypt(
            data,
            password: password,
            pbkdf2_iterations: Int32(Security.pinPBKDF2Iterations)
        )
    }
    
    /// Returns true if the BTC wallet is funded
    var isBitcoinWalletFunded: Bool {
        return getTotalActiveBalance() > 0
    }
}
