//
//  MockWalletRepository.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 10/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import PlatformKit

final class MockWalletRepository: WalletRepositoryAPI {

    private var expectedSessionToken: String?
    private var expectedAuthenticatorType: AuthenticatorType = .standard
    private var expectedGuid: String?
    private var expectedPayload: String?
    private var expectedSharedKey: String?
    private var expectedPassword: String?
    private var expectedSyncPubKeys = false

    var sessionToken: Single<String?> { .just(expectedSessionToken) }
    var payload: Single<String?> { .just(expectedPayload) }
    var sharedKey: Single<String?> { .just(expectedSharedKey) }
    var password: Single<String?> { .just(expectedPassword) }
    var guid: Single<String?> { .just(expectedGuid) }
    var authenticatorType: Single<AuthenticatorType> { .just(expectedAuthenticatorType) }
    
    func set(sessionToken: String) -> Completable {
        return perform { [weak self] in
            self?.expectedSessionToken = sessionToken
        }
    }
    
    func set(sharedKey: String) -> Completable {
        return perform { [weak self] in
            self?.expectedSharedKey = sharedKey
        }
    }
    
    func set(password: String) -> Completable {
        return perform { [weak self] in
            self?.expectedPassword = password
        }
    }

    func set(guid: String) -> Completable {
        return perform { [weak self] in
            self?.expectedGuid = guid
        }
    }
    
    func set(syncPubKeys: Bool) -> Completable {
        return perform { [weak self] in
            self?.expectedSyncPubKeys = syncPubKeys
        }
    }
    
    func set(language: String) -> Completable {
        return .empty()
    }
    
    func set(authenticatorType: AuthenticatorType) -> Completable {
        return perform { [weak self] in
            self?.expectedAuthenticatorType = authenticatorType
        }
    }
    
    func set(payload: String) -> Completable {
        return perform { [weak self] in
            self?.expectedPayload = payload
        }
    }
    
    func cleanSessionToken() -> Completable {
        return perform { [weak self] in
            self?.expectedSessionToken = nil
        }
    }
    
    private func perform(_ operation: @escaping () -> Void) -> Completable {
        return Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
    }
}
