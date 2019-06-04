//
//  EthereumKeyDerivationInput.swift
//  EthereumKit
//
//  Created by Jack on 08/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct EthereumKeyDerivationInput: KeyDerivationInput, Equatable {
    public let mnemonic: String
    public let password: String
    
    public init(mnemonic: String, password: String) {
        self.mnemonic = mnemonic
        self.password = password
    }
}
