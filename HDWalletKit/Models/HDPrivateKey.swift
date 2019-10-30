//
//  HDPrivateKey.swift
//  HDWalletKit
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import CommonCryptoKit
import LibWally

public struct HDPrivateKey: Equatable {
    
    public var xpriv: String? {
        return libWallyKey.xpriv
    }
    
    public var xpub: String {
        return libWallyKey.xpub
    }
    
    // FIXME: This is public for now but will eventually be private
    public let libWallyKey: LibWally.HDKey
    
    public init(seed: Seed, network: Network = .main(Bitcoin.self)) throws {
        guard let libWallySeed = BIP39Seed(seed.hexValue) else {
            throw HDWalletKitError.unknown
        }
        
        guard let key = LibWally.HDKey(libWallySeed, network.libWallyNetwork) else {
            throw HDWalletKitError.unknown
        }
        
        self.libWallyKey = key
    }
    
    // FIXME: This is public for now but will eventually be private
    public init(libWallyKey: LibWally.HDKey) {
        self.libWallyKey = libWallyKey
    }
    
    public func publicKey() -> HDPublicKey {
        return HDPublicKey(data: libWallyKey.pubKey)
    }
    
    public func derive(at path: HDKeyPath) throws -> HDPrivateKey {
        let key: LibWally.HDKey
        do {
            key = try libWallyKey.derive(path.libWallyPath)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        return HDPrivateKey(libWallyKey: key)
    }
    
    public static func == (lhs: HDPrivateKey, rhs: HDPrivateKey) -> Bool {
        return lhs.xpriv == rhs.xpriv
            && lhs.xpub == rhs.xpub
    }
    
}
