//
//  LegacyEthereumWalletMock.swift
//  BlockchainTests
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

@testable import PlatformKit
@testable import EthereumKit
@testable import PlatformUIKit
@testable import Blockchain

extension LegacyEthereumWalletAPI {
    var lastEthereumTransactionDetails: Single<LegacyLastTransactionDetails?> {
        return .just(nil)
    }
    var hasLastTransactionDetails: Single<Bool> {
        return lastEthereumTransactionDetails.map { $0 != nil }
    }
}

class MockLegacyEthereumWallet: LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI {
    
    // MARK: - LegacyWalletAPI
    
    func createOrderPayment(withOrderTransaction orderTransaction: OrderTransactionLegacy, completion: @escaping () -> Void, success: ((String) -> Void)!, error: @escaping (String) -> Void) {
        error("Not implemented")
    }
    
    func sendOrderTransaction(_ legacyAssetType: LegacyAssetType, secondPassword: String?, completion: @escaping () -> Void, success: @escaping () -> Void, error: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        error("Not implemented")
    }
        
    var receiveAddress: String = "ReceiveAddress"
    func getReceiveAddress(forAccount account: Int32, assetType: LegacyAssetType) -> String! {
        return receiveAddress
    }
    
    // MARK: - LegacyEthereumWalletProtocol
    
    enum MockLegacyEthereumWalletError: Error {
        case notInitialized
        case unknown
    }
                        
    var password: String? = "password"
    
    var checkIfEthereumAccountExistsValue = true
    func checkIfEthereumAccountExists() -> Bool {
        return checkIfEthereumAccountExistsValue
    }
    
    func recordLastEthereumTransaction(transactionHash: String,
                                       success: @escaping () -> Void,
                                       error: @escaping (String) -> Void) {
        success()
    }
    
    var needsSecondPasswordValue = false
    func needsSecondPassword() -> Bool {
        return needsSecondPasswordValue
    }
    
    static let legacyAccount = LegacyEthereumWalletAccount(
        addr: MockEthereumWalletTestData.account,
        label: "My ETH Wallet"
    )
    static let ethereumAccounts: [[String : Any]] = [[
        "addr": legacyAccount.addr,
        "label": legacyAccount.label
    ]]
    var ethereumAccountsCompletion: Result<[[String : Any]], MockLegacyEthereumWalletError> = .success(ethereumAccounts)
    func ethereumAccounts(with secondPassword: String?,
                          success: @escaping ([[String: Any]]) -> Void,
                          error: @escaping (String) -> Void) {
        switch ethereumAccountsCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let labelForAccount: String = "My ETH Wallet"
    var getLabelForEthereumAccountCompletion: Result<String, MockLegacyEthereumWalletError> = .success(labelForAccount)
    func getLabelForEthereumAccount(with secondPassword: String?,
                                    success: @escaping (String) -> Void,
                                    error: @escaping (String) -> Void) {
        switch getLabelForEthereumAccountCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var saveEthereumAccountCompletion: Result<Void, MockLegacyEthereumWalletError> = .success(())
    func saveEthereumAccount(with privateKey: String,
                             label: String?,
                             success: @escaping () -> Void,
                             error: @escaping (String) -> Void) {
        switch saveEthereumAccountCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var getEtherAddressCompletion: Result<String, MockLegacyEthereumWalletError> = .success("address")
    func getEthereumAddress(with secondPassword: String?,
                            success: @escaping (String) -> Void,
                            error: @escaping (String) -> Void) {
        switch getEtherAddressCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let ethBalanceValue: String = "1337"
    var fetchEthereumBalanceCalled: Bool = false
    var fetchEthereumBalancecCompletion: Result<String, MockLegacyEthereumWalletError> = .success(ethBalanceValue)
    func fetchEthereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        switch fetchEthereumBalancecCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var fetchHistoryCompletion: Result<Void, MockLegacyEthereumWalletError> = .success(())
    func fetchHistory(with secondPassword: String?, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        switch fetchHistoryCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let isWaitingOnTransactionValue: Bool = false
    var isWaitingOnTransactionCompletion: Result<Bool, MockLegacyEthereumWalletError> = .success(isWaitingOnTransactionValue)
    func isWaitingOnEthereumTransaction(with secondPassword: String?, success: @escaping (Bool) -> Void, error: @escaping (String) -> Void) {
        switch isWaitingOnTransactionCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var lastRecordedEtherTransactionHashAsync: String?
    var recordLastEthereumTransactionCompletion: Result<Void, MockLegacyEthereumWalletError> = .success(())
    func recordLastEthereumTransaction(with secondPassword: String?, transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        lastRecordedEtherTransactionHashAsync = transactionHash
        switch recordLastEthereumTransactionCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var getEtherTransactionNonceCompletion: Result<String, MockLegacyEthereumWalletError> = .success("1")
    func getEthereumTransactionNonce(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        switch getEtherTransactionNonceCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let tokenAccounts: [String: [String: Any]] = [
        "pax": [
            "label": "My PAX Wallet",
            "contract": "0x8E870D67F660D95d5be530380D0eC0bd388289E1",
            "has_seen": false,
            "tx_notes": [
                "transaction_hash": "memo"
            ]
        ]
    ]
    var erc20TokensCompletion: Result<[String: [String: Any]], MockLegacyEthereumWalletError> = .success(tokenAccounts)
    func erc20Tokens(with secondPassword: String?,
                     success: @escaping ([String: [String: Any]]) -> Void,
                     error: @escaping (String) -> Void) {
        switch erc20TokensCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var lastSavedTokensJSONString: String?
    var saveERC20TokensCompletion: Result<Void, MockLegacyEthereumWalletError> = .success(())
    func saveERC20Tokens(with secondPassword: String?,
                         tokensJSONString: String,
                         success: @escaping () -> Void,
                         error: @escaping (String) -> Void) {
        lastSavedTokensJSONString = tokensJSONString
        switch erc20TokensCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    // MARK: - MnemonicAccessAPI
    
    var mnemonicMaybe = Maybe.just("")
    var mnemonic: Maybe<String> {
        return mnemonicMaybe
    }
    
    var mnemonicForcePromptMaybe = Maybe.just("")
    var mnemonicForcePrompt: Maybe<String> {
        return mnemonicForcePromptMaybe
    }
    
    var mnemonicPromptingIfNeededMaybe = Maybe.just("")
    var mnemonicPromptingIfNeeded: Maybe<String> {
        return mnemonicPromptingIfNeededMaybe
    }
}
