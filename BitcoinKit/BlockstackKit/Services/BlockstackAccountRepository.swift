//
//  BlockstackAccountRepository.swift
//  BitcoinKit
//
//  Created by Jack on 22/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import HDWalletKit
import PlatformKit
import LibWally

public enum BlockstackError: Error {
    case addressDerivationFailed
    case unknown
}

public struct BlockstackAddress: RawRepresentable {
    
    public let rawValue: String
    
    public init?(rawValue value: String) {
        self.rawValue = value
    }
    
    init(address: Address) {
        self.rawValue = address.description
    }
    
}

public protocol BlockstackAccountAPI {
    
    var accountAddress: Single<BlockstackAddress> { get }
}

public final class BlockstackAccountRepository: BlockstackAccountAPI {
    
    public typealias Bridge =
          MnemonicAccessAPI
        & PasswordAccessAPI
    
    // MARK: - Public properties
    
    public var accountAddress: Single<BlockstackAddress> {
        return Maybe.zip(bridge.mnemonic, bridge.password)
            .asObservable()
            .asSingle()
            .flatMap(weak: self) { (self, tuple) -> Single<BlockstackAddress> in
                let (mnemonic, password) = tuple
                return self.addressDeriver.deriveAddress(
                        mnemonic: mnemonic,
                        password: password
                    )
                    .single
            }
    }
    
    // MARK: - Private properties
    
    private let bridge: Bridge
    private let client: APIClientAPI
    private let addressDeriver: BlockstackAddressDeriverAPI
    
    // MARK: - Init
    
    public convenience init(with bridge: Bridge) {
        self.init(with: bridge, client: APIClient(), addressDeriver: BlockstackAddressDeriver())
    }
    
    init(with bridge: Bridge, client: APIClientAPI, addressDeriver: BlockstackAddressDeriverAPI) {
        self.bridge = bridge
        self.client = client
        self.addressDeriver = addressDeriver
    }
}

protocol BlockstackAddressDeriverAPI {
    func deriveAddress(mnemonic: String, password: String) -> Result<BlockstackAddress, Error>
}

class BlockstackAddressDeriver: BlockstackAddressDeriverAPI {
    
    func deriveAddress(mnemonic: String, password: String) -> Result<BlockstackAddress, Error> {
        guard
            let mn = BIP39Mnemonic(mnemonic),
            let masterKey = HDKey(mn.seedHex()),
            let path = BIP32Path("m/44'/5757'/0'/0/0")
        else {
            return .failure(BlockstackError.addressDerivationFailed)
        }
        let key: LibWally.HDKey
        do {
            key = try masterKey.derive(path)
        } catch {
            return .failure(error)
        }
        let blockstackAddress = key.address(.payToPubKeyHash)
        return .success(BlockstackAddress(address: blockstackAddress))
    }
    
}
