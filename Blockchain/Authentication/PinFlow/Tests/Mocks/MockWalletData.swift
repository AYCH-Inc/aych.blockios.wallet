//
//  MockWallet.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@testable import Blockchain

class MockWalletData: WalletProtocol {
    
    @objc var password: String? = "password"
    @objc var isNew = true
    
    weak var delegate: WalletDelegate?
    private let initialized: Bool
    
    var isBitcoinWalletFunded: Bool { return false }
    
    init(initialized: Bool, delegate: WalletDelegate?) {
        self.initialized = initialized
        self.delegate = delegate
    }
    
    @objc func isInitialized() -> Bool {
        return initialized
    }
    
    @objc func encrypt(_ data: String, password: String) -> String {
        return password
    }
    
    /// When called, invokes the delegate's walletDidDecrypt and walletDidFinishLoad methods
    @objc func load(withGuid guid: String!, sharedKey: String!, password: String!) {
        delegate?.walletDidDecrypt!()
        delegate?.walletDidFinishLoad!()
    }
}
