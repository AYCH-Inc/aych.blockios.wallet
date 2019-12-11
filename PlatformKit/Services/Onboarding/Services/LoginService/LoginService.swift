//
//  LoginService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class LoginService: LoginServiceAPI {
    
    /// A potential login service error
    public enum ServiceError: Error {
        
        /// A 2FA required in order to complete the login
        case twoFactorOTPRequired(AuthenticatorType)
        
        /// A wrong code was sent
        case wrongCode(type: AuthenticatorType, attemptsLeft: Int)
        
        /// Account locked
        case accountLocked
        
        case message(String)
    }
    
    // MARK: - Properties
    
    private let payloadService: WalletPayloadServiceAPI
    private let twoFAPayloadService: TwoFAWalletServiceAPI
    private let walletRepository: WalletRepositoryAPI
    
    /// Keeps authenticator type. Defaults to `.none` unless
    /// `func login() -> Completable` sets it to a different value
    private let authenticatorRelay = BehaviorRelay(value: AuthenticatorType.standard)
    
    // MARK: - Setup
    
    public init(payloadService: WalletPayloadServiceAPI,
                twoFAPayloadService: TwoFAWalletServiceAPI,
                walletRepository: WalletRepositoryAPI) {
        self.payloadService = payloadService
        self.twoFAPayloadService = twoFAPayloadService
        self.walletRepository = walletRepository
    }
    
    // MARK: - API
    
    public func login(walletIdentifier: String) -> Completable {
        /// Set the wallet identifier as `GUID`
        return walletRepository
            .set(guid: walletIdentifier)
            .andThen(payloadService.requestUsingSessionToken())
            .catchError { error -> Single<AuthenticatorType> in
                switch error {
                case WalletPayloadService.ServiceError.accountLocked:
                    throw ServiceError.accountLocked
                case WalletPayloadService.ServiceError.message(let message):
                    throw ServiceError.message(message)
                default:
                    throw error
                }
            }
            // We have to keep the authenticator type
            // in case backend requires a 2FA OTP
            .do(onSuccess: { [weak authenticatorRelay] type in
                authenticatorRelay?.accept(type)
            })
            .flatMap { type -> Single<Void> in
                switch type {
                case .standard:
                    return .just(())
                default:
                    throw ServiceError.twoFactorOTPRequired(type)
                }
            }
            .asCompletable()
    }
    
    public func login(walletIdentifier: String, code: String) -> Completable {
        let authenticator = authenticatorRelay.value
        return twoFAPayloadService
            .send(code: code)
            .catchError { error -> Completable in
                switch error {
                case TwoFAWalletService.ServiceError.wrongCode(attemptsLeft: let attempts):
                    throw ServiceError.wrongCode(type: authenticator, attemptsLeft: attempts)
                case TwoFAWalletService.ServiceError.accountLocked:
                    throw ServiceError.accountLocked
                default:
                    throw error
                }
            }
    }
}
