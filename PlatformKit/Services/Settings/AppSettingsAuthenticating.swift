//
//  AppSettingsProtocol.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

enum AppSettingsCacheError: Error {
    case missingEncryptedPinPassword
}

@objc
public protocol AppSettingsAPI: class {
    @objc var sharedKey: String? { set get }
    @objc var guid: String? { set get }
}

// TICKET: https://blockchain.atlassian.net/browse/IOS-2738
// TODO: Refactor BlockchainSettings.App/Onboarding to support Rx and be thread-safe
/// Serves any authentication logic that should be extracted from the app settings
@objc
public protocol AppSettingsAuthenticating: class {
    @objc var pin: String? { get set }
    @objc var pinKey: String? { get set }
    @objc var biometryEnabled: Bool { get set }
    @objc var passwordPartHash: String? { get set }
    @objc var encryptedPinPassword: String? { get set }
}

// TICKET: https://blockchain.atlassian.net/browse/IOS-2738
// TODO: Refactor BlockchainSettings.App/Onboarding to support Rx and be thread-safe
public protocol ReactiveAppSettingsAuthenticating: AppSettingsAuthenticating {
    var encryptedPinPasswordSingle: Single<String> { get }
}

extension ReactiveAppSettingsAuthenticating {
    public var encryptedPinPasswordSingle: Single<String> {
        return Single
            .create(weak: self) { (self, observer) in
                guard let encryptedPinPassword = self.encryptedPinPassword else {
                    observer(.error(AppSettingsCacheError.missingEncryptedPinPassword))
                    return Disposables.create()
                }
                observer(.success(encryptedPinPassword))
                return Disposables.create()
            }
    }
}
