//
//  MockWalletCredentialsProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

struct MockWalletCredentialsProvider: WalletCredentialsProviding {
    static var validFake: MockWalletCredentialsProvider {
        return MockWalletCredentialsProvider(
            guid: "123-abc-456-def-789-ghi",
            sharedKey: "0123456789"
        )
    }
    
    let guid: String?
    let sharedKey: String!
    
    init(guid: String?, sharedKey: String?) {
        self.guid = guid
        self.sharedKey = sharedKey
    }
}
