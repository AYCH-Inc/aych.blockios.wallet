//
//  LegacyEthereumWalletAPI.swift
//  Blockchain
//
//  Created by Jack on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol LegacyEthereumWalletAPI {
    
    func isWaitingOnEtherTransaction() -> Bool

    func checkIfEthereumAccountExists() -> Bool
    
    func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String: Any]]) -> Void, error: @escaping (String) -> Void)
    func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func saveEthereumAccount(with privateKey: String, label: String?, success: @escaping () -> Void, error: @escaping (String) -> Void)
    func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    
    func fetchEthereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    
    func fetchHistory(with secondPassword: String?, success: @escaping () -> Void, error: @escaping (String) -> Void)
    func isWaitingOnEthereumTransaction(with secondPassword: String?, success: @escaping (Bool) -> Void, error: @escaping (String) -> Void)
    
    func recordLastEthereumTransaction(with secondPassword: String?, transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void)
    func getEthereumTransactionNonce(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    
    func erc20Tokens(with secondPassword: String?, success: @escaping ([String: [String: Any]]) -> Void, error: @escaping (String) -> Void)
    func saveERC20Tokens(with secondPassword: String?, tokensJSONString: String, success: @escaping () -> Void, error: @escaping (String) -> Void)
}
