//
//  MockWalletCredentialsProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain

class MockWalletCredentialsProvider: WalletCredentialsProviding {
    static var validFake: MockWalletCredentialsProvider {
        return MockWalletCredentialsProvider(
            legacyGuid: "123-abc-456-def-789-ghi",
            legacySharedKey: "0123456789",
            legacyPassword: "blockchain"
        )
    }
    
    let legacyGuid: String?
    let legacySharedKey: String?
    let legacyPassword: String?
    
    init(legacyGuid: String?, legacySharedKey: String?, legacyPassword: String?) {
        self.legacyGuid = legacyGuid
        self.legacySharedKey = legacySharedKey
        self.legacyPassword = legacyPassword
    }
}
