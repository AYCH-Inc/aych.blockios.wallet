//
//  StellarKeyPair.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct StellarKeyPair: KeyPair {
    public var secret: String {
        return privateKey.secret
    }
    
    public var accountID: String
    public var privateKey: StellarPrivateKey
    
    public init(accountID: String, secret: String) {
        self.accountID = accountID
        self.privateKey = StellarPrivateKey(secret: secret)
    }
}
