//
//  EmailVerificationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class EmailVerificationService: EmailVerificationServiceAPI {

    // MARK: - Types
    
    private enum ServiceError: Error {
        case emailNotVerified
        case pollCancelled
    }

    // MARK: - Properties
    
    private let authenticationService: NabuAuthenticationServiceAPI
    private let settingsService: SettingsServiceAPI & EmailSettingsServiceAPI
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - Setup
    
    public init(authenticationService: NabuAuthenticationServiceAPI,
                settingsService: SettingsServiceAPI & EmailSettingsServiceAPI) {
        self.authenticationService = authenticationService
        self.settingsService = settingsService
    }

    public func cancel() -> Completable {
        return Completable
            .create { [weak self] observer -> Disposable in
                self?.isActiveRelay.accept(false)
                observer(.completed)
                return Disposables.create()
            }
    }
    
    public func verifyEmail() -> Completable {
        return start()
            .flatMapCompletable(weak: self) { (self, _) -> Completable in
                return self.authenticationService.updateWalletInfo()
            }
    }
    
    public func requestVerificationEmail(to email: String, context: FlowContext?) -> Completable {
        return settingsService
            .update(email: email, context: context)
            .andThen(authenticationService.updateWalletInfo())
    }
    
    /// Start polling by triggering the wallet settings fetch
    private func start() -> Single<Void> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.isActiveRelay.accept(true)
                observer(.success(()))
                return Disposables.create()
            }
            .flatMap(waitForVerification)
    }
    
    /// Continues the polling only if it has not been cancelled
    private func `continue`() -> Single<Void> {
        return isActiveRelay
            .take(1)
            .asSingle()
            .map { isActive in
                guard isActive else {
                    throw ServiceError.pollCancelled
                }
                return ()
            }
            .do(onSuccess: settingsService.refresh)
    }
    
    /// Returns a Single that upon subscription waits until the email is verified.
    /// Only when it streams a value (`Void`) the email is considered `verified`.
    private func waitForVerification() -> Single<Void> {
        return self.continue()
            .flatMap(weak: self) { (self, _) -> Single<Void> in
                return self.settingsService.state
                    /// Get the first value and make sure the stream terminates
                    /// by converting it to a `Single`
                    .compactMap { $0.value }
                    .take(1)
                    .asSingle()
                    /// Make sure the email is verified, if not throw an error
                    .map(weak: self) { (self, settings) -> Void in
                        guard settings.isEmailVerified else {
                            throw ServiceError.emailNotVerified
                        }
                        return ()
                    }
                    /// If email is not verified try again
                    .catchError { error -> Single<Void> in
                        switch error {
                        case ServiceError.emailNotVerified:
                            return Single<Int>
                                .timer(
                                    .seconds(1),
                                    scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                                )
                                .flatMap(weak: self) { (self, _) -> Single<Void> in
                                    return self.waitForVerification()
                                }
                        default:
                            return self.cancel().andThen(Single.error(ServiceError.pollCancelled))
                        }
                    }
            }

    }
}
