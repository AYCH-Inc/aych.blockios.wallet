//
//  ExchangeAccountRepository.swift
//  Blockchain
//
//  Created by AlexM on 7/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import NetworkKit
import PlatformKit

protocol ExchangeAccountRepositoryAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    func syncDepositAddresses() -> Completable
    func syncDepositAddressesIfLinked() -> Completable
}

protocol ExchangeClientAPI {
    typealias LinkID = String
    
    var appSettings: BlockchainSettings.App { get }
    var communicatorAPI: NetworkCommunicatorAPI { get }
    func linkID(_ authenticationToken: String) -> Single<LinkID>
    func linkToExistingExchangeUser(authenticationToken: String, _ linkID: LinkID) -> Completable
    func syncDepositAddress(authenticationToken: String, _ accounts: [AssetAddress]) -> Completable
}

enum ExchangeLinkingAPIError: Error {
    case noLinkID
    case `unknown`
}

class ExchangeAccountRepository: ExchangeAccountRepositoryAPI {
    
    private let blockchainRepository: BlockchainDataRepository
    private let authenticationService: NabuAuthenticationServiceAPI
    private let clientAPI: ExchangeClientAPI
    private let accountRepository: AssetAccountRepositoryAPI
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         clientAPI: ExchangeClientAPI = ExchangeClient(communicatorAPI: NetworkCommunicator.shared),
         accountRepository: AssetAccountRepositoryAPI = AssetAccountRepository.shared) {
        self.blockchainRepository = blockchainRepository
        self.authenticationService = authenticationService
        self.clientAPI = clientAPI
        self.accountRepository = accountRepository
    }
    
    var hasLinkedExchangeAccount: Single<Bool> {
        return blockchainRepository
            .fetchNabuUser()
            .flatMap(weak: self, { (self, user) -> Single<Bool> in
                return Single.just(user.hasLinkedExchangeAccount)
        })
    }
    
    func syncDepositAddressesIfLinked() -> Completable {
        return hasLinkedExchangeAccount.flatMapCompletable(weak: self, { (self, linked) -> Completable in
            if linked {
                return self.syncDepositAddresses()
            } else {
                return Completable.empty()
            }
        })
    }
    
    func syncDepositAddresses() -> Completable {
        return Single.zip(
            authenticationService.getSessionToken(),
            accountRepository.accounts.asSingle()
            ).flatMapCompletable(weak: self, { (self, payload) -> Completable in
                let addresses = payload.1.map { return $0.address }
                return self.clientAPI.syncDepositAddress(authenticationToken: payload.0.token, addresses)
            }
        )
    }
}

class ExchangeClient: ExchangeClientAPI {
    var communicatorAPI: NetworkCommunicatorAPI
    var appSettings: BlockchainSettings.App
    
    init(communicatorAPI: NetworkCommunicatorAPI = NetworkCommunicator.shared,
         settings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.communicatorAPI = communicatorAPI
        self.appSettings = settings
    }
    
    func syncDepositAddress(authenticationToken: String, _ accounts: [AssetAddress]) -> Completable {
        let depositAddresses = Dictionary(accounts.map { ($0.depositAddress.type.symbol, $0.depositAddress.address) }) { _, last in last }
        let payload = ["addresses" : depositAddresses ]
        guard let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Completable.error(NetworkError.default)
        }
        let components = ["users", "deposit", "addresses"]
        guard let endpoint = URL.endpoint(apiURL, pathComponents: components) else {
            return Completable.error(NetworkError.default)
        }
        
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: [HttpHeaderField.authorization: authenticationToken],
            contentType: .json
        )
        return communicatorAPI.perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    func linkID(_ authenticationToken: String) -> Single<LinkID> {
        let fallback = fetchLinkIDPayload(authenticationToken).flatMap(weak: self) { (self, payload) -> Single<LinkID> in
            guard let linkID = payload["linkId"] else {
                return Single.error(ExchangeLinkingAPIError.noLinkID)
            }
            
            return Single.just(linkID)
        }
        return existingUserLinkIdentifier().ifEmpty(switchTo: fallback)
    }
    
    func linkToExistingExchangeUser(authenticationToken: String, _ linkID: LinkID) -> Completable {
        let payload = ["linkId": linkID]
        guard let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Completable.error(NetworkError.default)
        }
        let components = ["users", "link-account", "existing"]
        guard let endpoint = URL.endpoint(apiURL, pathComponents: components) else {
            return Completable.error(NetworkError.default)
        }
        
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: try? JSONEncoder().encode(payload),
            headers: [HttpHeaderField.authorization: authenticationToken],
            contentType: .json
        )
        return communicatorAPI.perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    func fetchLinkIDPayload(_ token: String) -> Single<Dictionary<String, String>> {
        guard let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Single.error(NetworkError.default)
        }
        let components = ["users", "link-account", "create", "start"]
        guard let endpoint = URL.endpoint(apiURL, pathComponents: components) else {
            return Single.error(NetworkError.default)
        }
        
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: nil,
            headers: [HttpHeaderField.authorization: token],
            contentType: .json
        )
        
        return communicatorAPI.perform(request: request)
    }
    
    private func existingUserLinkIdentifier() -> Maybe<LinkID> {
        if let identifier = appSettings.exchangeLinkIdentifier {
            return Maybe.just(identifier)
        } else {
            return Maybe.empty()
        }
    }
}
