//
//  StellarKeyDerivationInput.swift
//  StellarKit
//
//  Created by Jack on 08/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct StellarKeyDerivationInput: KeyDerivationInput, Equatable {
    /// The mnemonic phrase used to derive the key pair
    public let mnemonic: String
    
    /// An optional passphrase for deriving the key pair
    public let passphrase: String?
    
    /// The index of the wallet
    public let index: Int
    
    public init(mnemonic: String, passphrase: String? = nil, index: Int = 0) {
        self.mnemonic = mnemonic
        self.passphrase = passphrase
        self.index = index
    }
}
