//
//  KeyPairDeriver.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol KeyPairDeriverAPI {
    associatedtype Pair: KeyPair
    
    /// Derives a `KeyPair` given a mnemonic phrase.
    /// This action is deterministic (i.e. the same mnemonic + passphrase combination will create the
    /// same key pair).
    ///
    /// - Parameters:
    ///   - mnemonic: the mnemonic phrase used to derive the key pair for the new account
    ///   - passphrase: an optional passphrase for deriving the key pair
    ///   - index: the index of the wallet to create
    /// - Returns: the created `KeyPair`
    func derive(mnemonic: String, passphrase: String?, index: Int) -> Pair
}
