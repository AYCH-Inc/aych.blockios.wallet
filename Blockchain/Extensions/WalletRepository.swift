//
//  WalletRepository.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit

/// TODO: Remove `NSObject` when `Wallet` is killed
/// A bridge to `Wallet` since it is an ObjC object.
@objc
final class WalletRepository: NSObject, WalletRepositoryAPI, WalletCredentialsProviding {
    
    // MARK: - Types
    
    private struct JSSetter {
        
        /// Accepts "true" / "false" as parameter
        static let syncPubKeys = "MyWalletPhone.setSyncPubKeys(%@)"
        
        /// Accepts a String representing the language
        static let language = "MyWalletPhone.setLanguage(\"%@\")"
        
        /// Accepts a String representing the wallet payload
        static let payload = "MyWalletPhone.setEncryptedWalletData(\"%@\")"
    }
    
    private let authenticatorTypeRelay = BehaviorRelay<AuthenticatorType>(value: .standard)
    private let sessionTokenRelay = BehaviorRelay<String?>(value: nil)
    private let guidRelay = BehaviorRelay<String?>(value: nil)
    private let sharedKeyRelay = BehaviorRelay<String?>(value: nil)
    private let passwordRelay = BehaviorRelay<String?>(value: nil)

    // MARK: - Properties
    
    /// Streams the session token if exists
    var sessionToken: Single<String?> {
        return sessionTokenRelay
            .take(1)
            .asSingle()
    }
    
    /// Streams the GUID if exists
    var guid: Single<String?> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                let guid = self.settings.guid ?? self.guidRelay.value
                observer(.success(guid))
                return Disposables.create()
            }
    }
    
    /// Streams the shared key if exists
    var sharedKey: Single<String?> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                let sharedKey = self.settings.sharedKey ?? self.sharedKeyRelay.value
                observer(.success(sharedKey))
                return Disposables.create()
            }
    }
    
    /// Streams the password if exists
    var password: Single<String?> {
        return passwordRelay
            .take(1)
            .asSingle()
    }
    
    var authenticatorType: Single<AuthenticatorType> {
        return authenticatorTypeRelay
            .take(1)
            .asSingle()
    }
    
    private let jsScheduler = MainScheduler.instance
    private let settings: AppSettingsAPI

    private unowned let jsContextProvider: JSContextProviderAPI
    
    // MARK: - Setup
    
    init(jsContextProvider: JSContextProviderAPI, settings: AppSettingsAPI) {
        self.jsContextProvider = jsContextProvider
        self.settings = settings
    }
    
    // MARK: - Wallet Setters
    
    /// Sets GUID
    func set(guid: String) -> Completable {
        return perform { [weak guidRelay] in
            guidRelay?.accept(guid)
        }
    }
    
    /// Sets the session token
    func set(sessionToken: String) -> Completable {
        return perform { [weak sessionTokenRelay] in
            sessionTokenRelay?.accept(sessionToken)
        }
    }
    
    /// Cleans the session token
    func cleanSessionToken() -> Completable {
        return perform { [weak sessionTokenRelay] in
            sessionTokenRelay?.accept(nil)
        }
    }
    
    /// Sets Shared-Key
    func set(sharedKey: String) -> Completable {
        return perform { [weak sharedKeyRelay] in
            sharedKeyRelay?.accept(sharedKey)
        }
    }
    
    /// Sets Password
    func set(password: String) -> Completable {
        return perform { [weak passwordRelay] in
            passwordRelay?.accept(password)
        }
    }
    
    /// Sets Authenticator Type
    func set(authenticatorType: AuthenticatorType) -> Completable {
        return perform { [weak authenticatorTypeRelay] in
            authenticatorTypeRelay?.accept(authenticatorType)
        }
    }
    
    // MARK: - JS Setters
    
    /// Sets a boolean indicating whether the public keys should sync to the wallet
    func set(syncPubKeys: Bool) -> Completable {
        return perform { [weak jsContextProvider] in
            let value = syncPubKeys ? "true" : "false"
            let script = String(format: JSSetter.syncPubKeys, value)
            jsContextProvider?.jsContext.evaluateScript(script)
        }
    }
    
    /// Sets the language
    func set(language: String) -> Completable {
        return perform { [weak jsContextProvider] in
            let escaped = language.escapedForJS()
            let script = String(format: JSSetter.language, escaped)
            jsContextProvider?.jsContext.evaluateScript(script)
        }
    }
    
    /// Sets the wallet payload
    func set(payload: String) -> Completable {
        return perform { [weak jsContextProvider] in
            let escaped = payload.escapedForJS()
            let script = String(format: JSSetter.payload, escaped)
            jsContextProvider?.jsContext.evaluateScript(script)
        }
    }
    
    // MARK: - Accessors
    
    private func perform(_ operation: @escaping () -> Void) -> Completable {
        return Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
    
    // MARK: - Legacy: PLEASE DONT USE THESE UNLESS YOU MUST HOOK LEGACY OBJ-C CODE

    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    var legacyAuthentocatorType: AuthenticatorType {
        set {
            authenticatorTypeRelay.accept(newValue)
        }
        get {
            return authenticatorTypeRelay.value
        }
    }
    
    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacySessionToken: String? {
        set {
            sessionTokenRelay.accept(newValue)
        }
        get {
            return sessionTokenRelay.value
        }
    }
    
    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacyGuid: String? {
        set {
            guidRelay.accept(newValue)
        }
        get {
            return guidRelay.value
        }
    }

    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacyPassword: String? {
        set {
            passwordRelay.accept(newValue)
        }
        get {
            return passwordRelay.value
        }
    }
    
    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacySharedKey: String? {
        set {
            sharedKeyRelay.accept(newValue)
        }
        get {
            return sharedKeyRelay.value
        }
    }
}
