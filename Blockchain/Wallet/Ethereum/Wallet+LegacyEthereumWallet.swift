//
//  Wallet+LegacyEthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 29/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

@available(*, deprecated, message: "Used for JS integration only - should be removed when pending transaction logic is native")
public class LegacyLastTransactionDetails {
    let hash: String
    let date: Date
    
    init(hash: String, date: Date) {
        self.hash = hash
        self.date = date
    }
}

extension Wallet: LegacyEthereumWalletAPI {
    
    public func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String: Any]]) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getAccounts.addObserver { result in
            switch result {
            case .success(let accounts):
                success(accounts)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getEtherAccountsAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    public func saveEthereumAccount(with privateKey: String, label: String?, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.saveAccount.addObserver { result in
            switch result {
            case .success:
                success()
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let escapedPrivateKey = privateKey.escapedForJS()
        let function: String = "MyWalletPhone.saveEtherAccountAsync"
        let script: String
        if let escapedLabel = label?.escapedForJS() {
            script = "\(function)(\(escapedPrivateKey), \(escapedLabel))"
        } else {
            script = "\(function)(\(escapedPrivateKey)))"
        }
        context.evaluateScript(script)
    }
    
    public func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        self.ethereumAccounts(with: secondPassword, success: { accounts in
            guard
                let ethereumAccountsDicts = accounts as? [[String:Any]],
                let defaultAccount = ethereumAccountsDicts.first,
                let label = defaultAccount["label"] as? String
            else {
                error("No ethereum accounts.")
                return
            }
            success(label)
        }, error: { errorMessage in
            error(errorMessage)
        })
    }
    
    public func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        self.ethereumAccounts(with: secondPassword, success: { accounts in
            guard
                let ethereumAccountsDicts = accounts as? [[String:Any]],
                let defaultAccount = ethereumAccountsDicts.first,
                let addr = defaultAccount["addr"] as? String
            else {
                error("No ethereum accounts.")
                return
            }
            success(addr)
        }, error: { errorMessage in
            error(errorMessage)
        })
    }
    
    public func erc20Tokens(with secondPassword: String?, success: @escaping ([String: [String: Any]]) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getERC20Tokens.addObserver { result in
            switch result {
            case .success(let tokens):
                success(tokens)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getERC20TokensAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    public func saveERC20Tokens(with secondPassword: String?, tokensJSONString: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.saveERC20Tokens.addObserver { result in
            switch result {
            case .success:
                success()
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.setERC20TokensAsync"
        let escapedTokens = tokensJSONString
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\'\(escapedTokens)\', \(escapedSecondPassword))"
        } else {
            script = "\(function)(\'\(escapedTokens)\')"
        }
        context.evaluateScript(script)
    }
    
    @objc public func checkIfEthereumAccountExists() -> Bool {
        guard isInitialized() else { return false }
        return context.evaluateScript("MyWalletPhone.ethereumAccountExists()").toBool()
    }
        
    /// Checks of there is a last transaction details available (hash and timestamp)
    public var hasLastTransactionDetails: Single<Bool> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                let hasLastTxScript = "MyWalletPhone.hasLastEthTransaction()"
                observer(.success(self.context.evaluateScript(hasLastTxScript)?.toBool() ?? false))
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    /// Streams the last transaction details of `nil` if not found
    public var lastEthereumTransactionDetails: Single<LegacyLastTransactionDetails?> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                guard self.isInitialized() else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                let transactionHashScript = "MyWalletPhone.lastEthTransactionHash()"
                guard let transactionHash = self.context.evaluateScript(transactionHashScript)?.toString() else {
                    observer(.success(nil))
                    return Disposables.create()
                }
                
                let transactionTimestampScript = "MyWalletPhone.lastEthTransactionTimestamp()"
                guard let transactionTimestamp = self.context.evaluateScript(transactionTimestampScript)?.toDouble() else {
                    observer(.success(nil))
                    return Disposables.create()
                }
                
                observer(
                    .success(
                        LegacyLastTransactionDetails(
                            hash: transactionHash,
                            date: Date(timeIntervalSince1970: transactionTimestamp)
                        )
                    )
                )
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    public func recordLastEthereumTransaction(transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.recordLastTransaction.addObserver { result in
            switch result {
            case .success:
                success()
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let escapedTransactionHash = "'\(transactionHash.escapedForJS())'"
        let function: String = "MyWalletPhone.recordLastTransactionAsync"
        let script = "\(function)(\(escapedTransactionHash))"
        context.evaluateScript(script)
    }
}
