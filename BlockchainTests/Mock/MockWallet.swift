//
//  MockWallet.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockWallet: Wallet {

    var mockIsInitialized: Bool = false

    override func isInitialized() -> Bool {
        return mockIsInitialized
    }

    /// When called, invokes the delegate's walletDidDecrypt and walletDidFinishLoad methods
    override func load(withGuid guid: String!, sharedKey: String!, password: String!) {
        self.delegate?.walletDidDecrypt!()
        self.delegate?.walletDidFinishLoad!()
    }

    override func encrypt(_ data: String, password: String) -> String {
        return password
    }
}

/// Note: This is in `MockWallet` because `Wallet+Extensions` isn't
/// in the test target. Without this, the test target won't compile.
/// That said, currently no tests use this.
extension Wallet: CoinifyWalletBridgeAPI {
    func save(coinifyID: Int, token: String, completion: @escaping CoinifyAccountIDCompletion) {
        completion(nil)
    }
    
    func coinifyAccountID() -> Int? {
        return nil
    }
    
    func offlineToken() -> String? {
        return nil
    }
}
