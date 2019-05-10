//
//  CoinifyAccountRepository.swift
//  Blockchain
//
//  Created by AlexM on 4/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol CoinifyWalletBridgeAPI {
    typealias ErrorMessage = String
    typealias CoinifyAccountIDCompletion = (ErrorMessage?) -> Void
    
    func save(coinifyID: Int, token: String, completion: @escaping CoinifyAccountIDCompletion)
    func coinifyAccountID() -> Int?
    func offlineToken() -> String?
}

protocol CoinifyAccountRepositoryAPI {
    func save(accountID: Int, token: String) -> Completable
    func coinifyMetadata() -> Maybe<CoinifyMetadata>
    func hasCoinifyAccount() -> Bool
}

class CoinifyAccountRepository: CoinifyAccountRepositoryAPI {
    
    enum CoinifyAccountRepositoryError: Error {
        case `default`(CoinifyWalletBridgeAPI.ErrorMessage)
    }
    
    private let bridge: CoinifyWalletBridgeAPI
    
    init(bridge: CoinifyWalletBridgeAPI) {
        self.bridge = bridge
    }
    
    // MARK: CoinifyAccountRepositoryAPI
    
    func save(accountID: Int, token: String) -> Completable {
        return Completable.create(subscribe: { observer -> Disposable in
            self.bridge.save(coinifyID: accountID, token: token, completion: { message in
                if let value = message {
                    observer(.error(CoinifyAccountRepositoryError.default(value)))
                } else {
                    observer(.completed)
                }
            })
            return Disposables.create()
        })
    }
    
    func hasCoinifyAccount() -> Bool {
        return (bridge.coinifyAccountID() != nil && bridge.offlineToken() != nil)
    }
    
    func coinifyMetadata() -> Maybe<CoinifyMetadata> {
        guard let token = bridge.offlineToken() else {
            return Maybe.empty()
        }
        guard let accountID = bridge.coinifyAccountID() else {
            return Maybe.empty()
        }
        let data = CoinifyMetadata(identifier: accountID, token: token)
        return Maybe.just(data)
    }
}
