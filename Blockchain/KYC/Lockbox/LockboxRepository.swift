//
//  LockboxRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol LockboxRepositoryAPI: class {
    var hasLockbox: Bool { get }
    func lockboxes() -> [Lockbox]
}

/// Repository for accessing `Lockbox` objects
final class LockboxRepository: LockboxRepositoryAPI {

    /// Returns `true` if the user has a linked lockbox
    var hasLockbox: Bool {
        return !lockboxes().isEmpty
    }
    
    private let wallet: Wallet

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    /// Returns a list of `Lockbox` instances that have been synced with this
    /// Blockchain wallet.
    ///
    /// - Returns: the Lockbox instances
    func lockboxes() -> [Lockbox] {
        let lockboxDevicesRaw = wallet.getLockboxDevices()

        guard !lockboxDevicesRaw.isEmpty else {
            return []
        }

        return lockboxDevicesRaw.castJsonObjects(type: Lockbox.self)
    }
}
