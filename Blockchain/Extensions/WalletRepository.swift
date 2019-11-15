//
//  WalletRepository.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol WalletRepositoryAPI: SessionTokenRepositoryAPI, GuidRepositoryAPI {}

/// A bridge to `Wallet` since it is an ObjC object.
final class WalletRepository: WalletRepositoryAPI {
    
    var sessionToken: String! {
        set {
            wallet.sessionToken = newValue
        }
        get {
            return wallet.sessionToken
        }
    }
    
    var guid: String? {
        set {
            wallet.guid = newValue
        }
        get {
            return wallet.guid
        }
    }

    private let wallet: Wallet
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }
}
