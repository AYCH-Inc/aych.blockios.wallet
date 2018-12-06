//
//  MockXlmWallet.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import StellarKit
import PlatformKit
import RxSwift
@testable import Blockchain

class MockStellarBridge: StellarWalletBridgeAPI, MnemonicAccessAPI {
    
    var didCallSave: XCTestExpectation?
    var accounts: [StellarWalletAccount] = []
    
    func save(keyPair: StellarKeyPair, label: String, completion: @escaping MockStellarBridge.KeyPairSaveCompletion) {
        let account = StellarWalletAccount(index: 0, publicKey: keyPair.accountID, label: label, archived: false)
        accounts.append(account)
        completion(nil)
    }

    func stellarWallets() -> [StellarWalletAccount] {
        return accounts
    }
    
    // MARK: MnemonicAccessAPI
    
    var mnemonic: Maybe<String> {
        return Maybe.empty()
    }
    
    var mnemonicForcePrompt: Maybe<String> {
        return Maybe.empty()
    }
    
    var mnemonicPromptingIfNeeded: Maybe<String> {
        return Maybe.empty()
    }
    
}
