//
//  PITAccountRepository.swift
//  Blockchain
//
//  Created by AlexM on 7/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

protocol PITAccountRepositoryAPI {
    var hasLinkedPITAccount: Single<Bool> { get }
    func syncDepositAddresses() -> Completable
    func syncDepositAddressesIfLinked() -> Completable
}

protocol PITClientAPI {
    typealias LinkID = String
    
    var appSettings: BlockchainSettings.App { get }
    var communicatorAPI: NetworkCommunicatorAPI { get }
    func linkID(_ authenticationToken: String) -> Single<LinkID>
    func linkToExistingPitUser(authenticationToken: String, _ linkID: LinkID) -> Completable
    func syncDepositAddress(authenticationToken: String, _ accounts: [AssetAddress]) -> Completable
}

enum PITLinkingAPIError: Error {
    case noLinkID
    case `unknown`
}

class PITAccountRepository: PITAccountRepositoryAPI {
    
    private let blockchainRepository: BlockchainDataRepository
    private let authenticationService: NabuAuthenticationServiceAPI
    private let clientAPI: PITClientAPI
    private let accountRepository: AssetAccountRepositoryAPI
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         clientAPI: PITClientAPI = PITClient(communicatorAPI: NetworkCommunicator.shared),
         accountRepository: AssetAccountRepositoryAPI = AssetAccountRepository.shared) {
        self.blockchainRepository = blockchainRepository
        self.authenticationService = authenticationService
        self.clientAPI = clientAPI
        self.accountRepository = accountRepository
    }
    
    var hasLinkedPITAccount: Single<Bool> {
        return blockchainRepository
            .fetchNabuUser()
            .flatMap(weak: self, { (self, user) -> Single<Bool> in
                return Single.just(user.hasLinkedPITAccount)
        })
    }
    
    func syncDepositAddressesIfLinked() -> Completable {
        return hasLinkedPITAccount.flatMapCompletable(weak: self, { (self, linked) -> Completable in
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

class PITClient: PITClientAPI {
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
                return Single.error(PITLinkingAPIError.noLinkID)
            }
            
            return Single.just(linkID)
        }
        return existingUserLinkIdentifier().ifEmpty(switchTo: fallback)
    }
    
    func linkToExistingPitUser(authenticationToken: String, _ linkID: LinkID) -> Completable {
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
        if let identifier = appSettings.pitLinkIdentifier {
            return Maybe.just(identifier)
        } else {
            return Maybe.empty()
        }
    }
}
