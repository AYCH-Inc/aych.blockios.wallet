//
//  EthereumPrivateKey.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct EthereumPrivateKey: Equatable {
    public var mnemonic: String
    public var password: String
    
    public init(mnemonic: String, password: String) {
        self.mnemonic = mnemonic
        self.password = password
    }
}
