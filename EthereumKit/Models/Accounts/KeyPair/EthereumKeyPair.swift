//
//  EthereumKeyPair.swift
//  EthereumKit
//
//  Created by Jack on 03/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct EthereumKeyPair: KeyPair, Equatable {
    public var accountID: String
    public var privateKey: EthereumPrivateKey
    
    public init(accountID: String, privateKey: EthereumPrivateKey) {
        self.accountID = accountID
        self.privateKey = privateKey
    }
}
