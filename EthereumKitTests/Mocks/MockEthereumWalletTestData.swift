//
//  MockEthereumWalletTestData.swift
//  EthereumKitTests
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import BigInt
import CommonCryptoKit
@testable import TestKit
@testable import EthereumKit

struct MockEthereumWalletTestData {
    static let walletId = MockWalletTestData.walletId
    static let email = MockWalletTestData.email
    
    static let mnemonic = MockWalletTestData.mnemonic
    static let password = MockWalletTestData.password
    static let account = "0xE408d13921DbcD1CBcb69840e4DA465Ba07B7e5e".lowercased()
    
    static let privateKeyHex = "de6e182c9456edeb1148387dadc8f981905377279feb9547d095152ef0f569d9"
    static let privateKeyBase64 = "3m4YLJRW7esRSDh9rcj5gZBTdyef65VH0JUVLvD1adk="
    static let privateKeyData = Data(hex: MockEthereumWalletTestData.privateKeyHex)
    
    static let privateKey = EthereumPrivateKey(
        mnemonic: MockEthereumWalletTestData.mnemonic,
        password: MockEthereumWalletTestData.password,
        data: MockEthereumWalletTestData.privateKeyData
    )
    static let keyPair = EthereumKeyPair(
        accountID: MockEthereumWalletTestData.account,
        privateKey: MockEthereumWalletTestData.privateKey
    )
    
    struct Transaction {
        static let to = "0x3535353535353535353535353535353535353535"
        static let value: BigUInt = 1
        static let nonce: BigUInt = 9
        static let gasPrice: BigUInt = 11_000_000_000
        static let gasLimit: BigUInt = 21_000
        static let gasLimitContract: BigUInt = 65_000
        static let data: Data? = Data()
    }
}
