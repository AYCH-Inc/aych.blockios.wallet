//
//  EmailVerificationService.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

enum VerifyEmailError: Error {
    case invalidWalletState
}

class EmailVerificationService: EmailVerifierAPI {

    private let appSettings: BlockchainSettings.App
    private let authenticationService: NabuAuthenticationService
    private let walletSettings: WalletSettingsAPI
    private let repository: BlockchainDataRepository

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        walletSettings: WalletSettingsAPI = WalletSettingsService(),
        repository: BlockchainDataRepository = BlockchainDataRepository.shared
    ) {
        self.appSettings = appSettings
        self.authenticationService = authenticationService
        self.walletSettings = walletSettings
        self.repository = repository
    }

    /// Waits until the email is verified by the user. Once the email is verified, the Completable sequence will complete
    ///
    /// This works by polling WalletService every 1 sec, and if the email is verified, it will call sync on the wallet-nabu
    /// synchronizer.
    func waitForEmailVerification() -> Observable<Bool> {
        return pollWalletSettings()
            .map { $0.emailVerified }
            .distinctUntilChanged()
            .filter { $0 }
            .flatMap { [weak self] isVerified -> Observable<Bool> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                guard isVerified else {
                    return Observable.just(false)
                }
                return strongSelf.authenticationService.updateWalletInfo().andThen(
                    Observable.just(true)
                )
            }
    }

    func sendVerificationEmail(to email: EmailAddress, contextParameter: ContextParameter?) -> Completable {
        guard let guid = appSettings.guid else {
            Logger.shared.warning("Cannot update last-tx-time, guid is nil.")
            return Completable.error(VerifyEmailError.invalidWalletState)
        }
        guard let sharedKey = appSettings.sharedKey else {
            Logger.shared.warning("Cannot update last-tx-time, sharedKey is nil.")
            return Completable.error(VerifyEmailError.invalidWalletState)
        }
        
        return walletSettings.updateEmail(email: email, guid: guid, sharedKey: sharedKey, context: contextParameter).andThen(
            authenticationService.updateWalletInfo()
        )
    }
    
    var userEmail: Single<Email> {
        return repository.nabuUser.take(1).asSingle().flatMap {
            return Single.just($0.email)
        }
    }

    // MARK: Private Methods

    func pollWalletSettings() -> Observable<WalletSettings> {
        return Observable<Int>.interval(
            1,
            scheduler: MainScheduler.asyncInstance
        ).flatMap { [weak self] _ -> Observable<WalletSettings> in
            guard let strongSelf = self else {
                return Observable.empty()
            }
            guard let guid = strongSelf.appSettings.guid else {
                return Observable.error(VerifyEmailError.invalidWalletState)
            }

            guard let sharedKey = strongSelf.appSettings.sharedKey else {
                return Observable.error(VerifyEmailError.invalidWalletState)
            }
            return strongSelf.walletSettings.fetchSettings(guid: guid, sharedKey: sharedKey)
                .asObservable()
        }
    }
}
