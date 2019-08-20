//
//  HDKeychain.swift
//  HDWalletKit
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally

public struct HDKeychain {
    
    public let privateKey: HDPrivateKey
    
    public init(privateKey: HDPrivateKey) {
        self.privateKey = privateKey
    }
    
    public init(mnemonic: Mnemonic, network: Network) throws {
        guard let seed = mnemonic.seed else {
            throw HDWalletKitError.unknown
        }
        let privateKey: HDPrivateKey
        do {
            privateKey = try HDPrivateKey(seed: seed, network: network)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        self.privateKey = privateKey
    }
    
    public func derivedKey(path: HDKeyPath) throws -> HDPrivateKey {
        return try privateKey.derive(at: path)
    }
}
