//
//  PinLoginService.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public struct Security {
    /// This does not need to be large because the key is already 256 bits
    public static let pinPBKDF2Iterations = 1
}

public final class PinLoginService: PinLoginServiceAPI {
    
    // MARK: - Types
    
    public typealias PasscodeRepositoryAPI = SharedKeyRepositoryAPI & GuidRepositoryAPI & PasswordRepositoryAPI
    
    /// Potential errors
    public enum ServiceError: Error {
        case missingEncryptedPassword
        case walletDecryption
        case emptyDecryptedPassword
        case missingGuid
        case missingSharedKey
    }
    
    private struct JSMethod {
        
        /// This method is used to decrypt the password using the pin decryption key
        static let decrypt = "WalletCrypto.decryptPasswordWithProcessedPin(\"%@\", \"%@\", %d)"
    }
    
    // MARK: - Properties
    
    private let jsContextProvider: JSContextProviderAPI
    private let settings: ReactiveAppSettingsAuthenticating
    private let service: WalletPayloadServiceAPI
    private let walletRepository: PasscodeRepositoryAPI
    
    // MARK: - Setup
    
    public init(jsContextProvider: JSContextProviderAPI,
         settings: ReactiveAppSettingsAuthenticating,
         service: WalletPayloadServiceAPI,
         walletRepository: PasscodeRepositoryAPI) {
        self.jsContextProvider = jsContextProvider
        self.service = service
        self.settings = settings
        self.walletRepository = walletRepository
    }
    
    public func password(from pinDecryptionKey: String) -> Single<String> {
        return service
            .requestUsingSharedKey()
            .flatMapSingle(weak: self) { (self) -> Single<PasscodePayload> in
                return Single
                    .zip(
                        self.walletRepository.guid,
                        self.decrypt(pinDecryptionKey: pinDecryptionKey),
                        self.walletRepository.sharedKey
                    )
                    .map { payload -> PasscodePayload in
                        // All the values must be present at the moment of invocation
                        return PasscodePayload(
                            guid: payload.0!,
                            password: payload.1,
                            sharedKey: payload.2!
                        )
                    }
            }
            .flatMap(weak: self) { (self, payload) -> Single<String> in
                return self.cache(passcodePayload: payload)
                    .andThen(Single.just(payload.password))
            }
    }
    
    /// Caches the passcode payload using wallet repository
    private func cache(passcodePayload: PasscodePayload) -> Completable {
        return Completable
            .zip(
                walletRepository.set(sharedKey: passcodePayload.sharedKey),
                walletRepository.set(password: passcodePayload.password),
                walletRepository.set(guid: passcodePayload.guid)
            )
    }
    
    /// TODO: Decrypt password natively
    /// Decrypt the password using the PIN decryption key
    private func decrypt(pinDecryptionKey: String) -> Single<String> {
        return Single.create(weak: self) { (self, observer) -> Disposable in
            guard let encryptedPassword = self.settings.encryptedPinPassword else {
                observer(.error(ServiceError.missingEncryptedPassword))
                return Disposables.create()
            }
            do {
                let password = try self.decrypt(
                    encryptedPassword: encryptedPassword,
                    using: pinDecryptionKey,
                    iterations: Security.pinPBKDF2Iterations
                )
                observer(.success(password))
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
        /// TODO: Remove subscription on `MainScheduler.instance`
        /// when the decryption becomes native
        .subscribeOn(MainScheduler.instance)
    }
    
    /// TICKET: https://blockchain.atlassian.net/browse/IOS-2735
    /// TODO: Decrypt password natively
    private func decrypt(encryptedPassword: String, using pinDecryptionKey: String, iterations: Int) throws -> String {
        let encryptedPassword = encryptedPassword.escapedForJS()
        let pinDecryptionKey = pinDecryptionKey.escapedForJS()
        let script = String(format: JSMethod.decrypt, encryptedPassword, pinDecryptionKey, Int32(iterations))
        guard let decryptedPassword = jsContextProvider.jsContext.evaluateScript(script)?.toString() else {
            throw ServiceError.walletDecryption
        }
        guard !decryptedPassword.isEmpty else {
            throw ServiceError.emptyDecryptedPassword
        }
        return decryptedPassword
    }
}
