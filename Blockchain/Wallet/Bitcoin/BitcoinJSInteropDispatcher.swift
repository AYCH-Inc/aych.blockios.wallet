//
//  BitcoinJSInteropDispatcher.swift
//  Blockchain
//
//  Created by Jack on 12/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc public protocol BitcoinJSInteropDelegateAPI {
    
    func didGetDefaultWalletIndex(_ walletIndex: JSValue)
    func didFailToGetDefaultWalletIndex(errorMessage: JSValue)
    
    func didGetAccounts(_ accounts: JSValue)
    func didFailToGetAccounts(errorMessage: JSValue)
}

protocol BitcoinJSInteropDispatcherAPI {
    
    var getDefaultWalletIndex: Dispatcher<Int> { get }
    
    var getAccounts: Dispatcher<String> { get }
}

public class BitcoinJSInteropDispatcher: BitcoinJSInteropDispatcherAPI {
    
    static let shared = BitcoinJSInteropDispatcher()
    
    let getDefaultWalletIndex = Dispatcher<Int>()
    
    let getAccounts = Dispatcher<String>()
}

extension BitcoinJSInteropDispatcher: BitcoinJSInteropDelegateAPI {
    
    public func didGetDefaultWalletIndex(_ walletIndex: JSValue) {
        guard let walletIndexInt = walletIndex.toNumber()?.intValue else {
            getDefaultWalletIndex.sendFailure(.unknown)
            return
        }
        getDefaultWalletIndex.sendSuccess(with: walletIndexInt)
    }
    
    public func didFailToGetDefaultWalletIndex(errorMessage: JSValue) {
        sendFailure(dispatcher: getDefaultWalletIndex, errorMessage: errorMessage)
    }
    
    public func didGetAccounts(_ accounts: JSValue) {
        guard let accountsString = accounts.toString() as? String else {
            getAccounts.sendFailure(.unknown)
            return
        }
        getAccounts.sendSuccess(with: accountsString)
    }
    
    public func didFailToGetAccounts(errorMessage: JSValue) {
        sendFailure(dispatcher: getAccounts, errorMessage: errorMessage)
    }
    
    private func sendFailure<T>(dispatcher: Dispatcher<T>, errorMessage: JSValue) {
        guard let message = errorMessage.toString() else {
            dispatcher.sendFailure(.unknown)
            return
        }
        dispatcher.sendFailure(.jsError(message))
    }
}
