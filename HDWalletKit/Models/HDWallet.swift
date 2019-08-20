//
//  HDWallet.swift
//  HDWalletKit
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally

public struct HDWallet {
    
    public var privateKey: HDPrivateKey {
        return keychain.privateKey
    }
    
    private let keychain: HDKeychain
    
    public init(keychain: HDKeychain) {
        self.keychain = keychain
    }
    
    public init(mnemonic: Mnemonic, network: Network) throws {
        let keychain: HDKeychain
        do {
            keychain = try HDKeychain(mnemonic: mnemonic, network: network)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        self.keychain = keychain
    }
    
    public func privateKey(path: HDKeyPath) throws -> HDPrivateKey {
        return try keychain.derivedKey(path: path)
    }
    
    public func publicKey() throws -> HDPublicKey {
        return keychain.privateKey.publicKey()
    }
    
    public func publicKey(at path: HDKeyPath) throws -> HDPublicKey {
        return try privateKey(path: path).publicKey()
    }
    
}
