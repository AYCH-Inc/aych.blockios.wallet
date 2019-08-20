//
//  BitcoinKeyPairDeriver.swift
//  BitcoinKit
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import HDWalletKit
import RxSwift

public struct BitcoinPrivateKey: Equatable {
    public let key: HDPrivateKey
    
    init(key: HDPrivateKey) {
        self.key = key
    }
}

public struct BitcoinKeyPair: KeyPair, Equatable {
    
    public var publicKey: String {
        return privateKey.key.xpub
    }
    
    public var privateKey: BitcoinPrivateKey
    
    public init(privateKey: BitcoinPrivateKey) {
        self.privateKey = privateKey
    }
}

public struct BitcoinKeyDerivationInput: KeyDerivationInput, Equatable {
    public let mnemonic: String
    public let password: String
    
    public init(mnemonic: String, password: String) {
        self.mnemonic = mnemonic
        self.password = password
    }
}

public protocol BitcoinKeyPairDeriverAPI: KeyPairDeriverAPI where Input == BitcoinKeyDerivationInput, Pair == BitcoinKeyPair {
    func derive(input: Input) -> Result<Pair, Error>
}

public class AnyBitcoinKeyPairDeriver: BitcoinKeyPairDeriverAPI {
    
    private let deriver: AnyKeyPairDeriver<BitcoinKeyPair, BitcoinKeyDerivationInput>
    
    // MARK: - Init
    
    public convenience init() {
        self.init(with: BitcoinKeyPairDeriver())
    }
    
    public init<D: KeyPairDeriverAPI>(with deriver: D) where D.Input == BitcoinKeyDerivationInput, D.Pair == BitcoinKeyPair {
        self.deriver = AnyKeyPairDeriver<BitcoinKeyPair, BitcoinKeyDerivationInput>(deriver: deriver)
    }
    
    public func derive(input: BitcoinKeyDerivationInput) -> Result<BitcoinKeyPair, Error> {
        return deriver.derive(input: input)
    }
}

public class BitcoinKeyPairDeriver: BitcoinKeyPairDeriverAPI {
    
    public func derive(input: BitcoinKeyDerivationInput) -> Result<BitcoinKeyPair, Error> {
        let mnemonic = input.mnemonic
        let passphrase = Passphrase(rawValue: input.password)
        let words: Words
        let mnemonics: HDWalletKit.Mnemonic
        let wallet: HDWallet
        do {
            words = try Words(words: mnemonic)
            mnemonics = try Mnemonic(words: words, passphrase: passphrase)
            wallet = try HDWallet(mnemonic: mnemonics, network: .main(Bitcoin.self))
        } catch {
            return .failure(error)
        }
        let privateKey = BitcoinPrivateKey(
            key: wallet.privateKey
        )
        return .success(BitcoinKeyPair(privateKey: privateKey))
    }
    
}
