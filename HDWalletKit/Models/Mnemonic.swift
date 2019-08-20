//
//  Mnemonic.swift
//  HDWalletKit
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally
import CommonCryptoKit

public struct Passphrase: LosslessStringConvertible, RawRepresentable {
    
    public var description: String {
        return rawValue
    }
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init?(_ description: String) {
        self.rawValue = description
    }
    
}

public struct Words {
    
    public let value: [String]
    
    public init(words: [String]) throws {
        guard let _ = BIP39Mnemonic(words) else {
            throw HDWalletKitError.unknown
        }
        self.value = words
    }
    
    public init(words: String) throws {
        try self.init(words: words.components(separatedBy: " "))
    }
    
}

public struct Mnemonic {
    
    public enum Strength: Int {
        case normal = 128
        case high = 256
    }
    
    public var seed: Seed? {
        let bip39seed = libWallyMnemonic.seedHex(passphrase?.rawValue)
        let data = Data(hex: bip39seed.description)
        return Seed(data: data)
    }
    
    private let words: Words
    private let passphrase: Passphrase?
    private let libWallyMnemonic: BIP39Mnemonic
    
    public init(entropy: Entropy, passphrase: Passphrase? = nil) throws {
        guard
            let entropy = BIP39Entropy(entropy.hexValue),
            let libWallyMnemonic = BIP39Mnemonic(entropy)
        else {
            throw HDWalletKitError.unknown
        }
        let words = try Words(words: libWallyMnemonic.words)
        self.words = words
        self.passphrase = passphrase
        self.libWallyMnemonic = libWallyMnemonic
    }
    
    public init(words: Words, passphrase: Passphrase? = nil) throws {
        guard let libWallyMnemonic = BIP39Mnemonic(words.value) else {
            throw HDWalletKitError.unknown
        }
        self.words = words
        self.passphrase = passphrase
        self.libWallyMnemonic = libWallyMnemonic
    }
    
    // TODO:
    // * This needs to be rewritten with a proper source of entropy
    @available(*, deprecated, message: "Don't use this! this is insecure")
    public static func create(passphrase: Passphrase? = nil, strength: Strength = .normal, language: WordList = WordList.default) throws -> Mnemonic {
        let entropy = Entropy.create(size: strength.rawValue)
        return try Mnemonic(entropy: entropy, passphrase: passphrase)
    }
    
}


