//
//  WalletPayloadService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class WalletPayloadService: WalletPayloadServiceAPI {
    
    // MARK: - Types
    
    enum ServiceError: Error {
        case unspported2FAType
        case accountLocked
        case message(String)
    }
    
    // MARK: - Properties
    
    private let client: WalletPayloadClientAPI
    private let repository: WalletRepositoryAPI

    // MARK: - Setup
    
    public init(client: WalletPayloadClientAPI = WalletPayloadClient(), repository: WalletRepositoryAPI) {
        self.client = client
        self.repository = repository
    }
        
    // MARK: - API
    
    public func requestUsingSessionToken() -> Single<AuthenticatorType> {
        return Single
            .zip(repository.guid, repository.sessionToken)
            .flatMap(weak: self) { (self, credentials) -> Single<AuthenticatorType> in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sessionToken = credentials.1 else {
                    throw MissingCredentialsError.sessionToken
                }
                return self.request(guid: guid, sessionToken: sessionToken)
            }
    }
    
    public func requestUsingSharedKey() -> Completable {
        return Single
            .zip(repository.guid, repository.sharedKey)
            .flatMapCompletable(weak: self) { (self, credentials) -> Completable in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sharedKey = credentials.1 else {
                    throw MissingCredentialsError.sharedKey
                }
                return self.request(guid: guid, sharedKey: sharedKey)
            }
    }
    
    /// Performs the request using cached GUID and shared key
    private func request(guid: String, sharedKey: String) -> Completable {
        return client
            .payload(guid: guid, identifier: .sharedKey(sharedKey))
            .flatMap(weak: self) { (self, response) -> Single<WalletPayloadClient.ClientResponse> in
                return self.cacheWalletData(from: response)
            }
            .asCompletable()
    }
    
    /// Performs the request using cached GUID and session-token
    private func request(guid: String, sessionToken: String) -> Single<AuthenticatorType> {
        return client
            .payload(guid: guid, identifier: .sessionToken(sessionToken))
            .flatMap(weak: self) { (self, response) -> Single<WalletPayloadClient.ClientResponse> in
                return self.cacheWalletData(from: response)
            }
            .map(weak: self) { (self, response) -> AuthenticatorType in
                guard let type = AuthenticatorType(rawValue: response.authType) else {
                    throw ServiceError.unspported2FAType
                }
                return type
            }
            .catchError { error -> Single<AuthenticatorType> in
                switch error {
                case WalletPayloadClient.ClientError.emailAuthorizationRequired:
                    return .just(.email)
                case WalletPayloadClient.ClientError.accountLocked:
                    throw ServiceError.accountLocked
                case WalletPayloadClient.ClientError.message(let message):
                    throw ServiceError.message(message)
                default:
                    throw error
                }
            }
    }
    
    /// Used to cache the client response
    private func cacheWalletData(from clientResponse: WalletPayloadClient.ClientResponse) -> Single<WalletPayloadClient.ClientResponse> {
        return Completable
            .zip(
                repository.set(guid: clientResponse.guid),
                repository.set(language: clientResponse.language),
                repository.set(syncPubKeys: clientResponse.shouldSyncPubkeys)
            )
            .flatMap(weak: self) { (self) -> Completable in
                guard let type = AuthenticatorType(rawValue: clientResponse.authType) else {
                    throw ServiceError.unspported2FAType
                }
                return self.repository.set(authenticatorType: type)
            }
            .flatMap(weak: self) { (self) -> Completable in
                if let rawPayload = clientResponse.payload?.stringRepresentation, !rawPayload.isEmpty {
                    return self.repository.set(payload: rawPayload)
                }
                return .empty()
            }
            .andThen(Single.just(clientResponse))
    }
}
