//
//  KYCVerifyEmailInteractor.swift
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

class KYCVerifyEmailInteractor {

    private let appSettings: BlockchainSettings.App
    private let authenticationService: NabuAuthenticationService
    private let dataRepository: BlockchainDataRepository
    private let walletSettings: WalletSettingsAPI
    private let walletService: WalletService

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
        walletSettings: WalletSettingsAPI = WalletSettingsService(),
        walletService: WalletService = WalletService.shared
    ) {
        self.appSettings = appSettings
        self.authenticationService = authenticationService
        self.dataRepository = dataRepository
        self.walletSettings = walletSettings
        self.walletService = walletService
    }

    // DEBUG CODE - remove and use `pollEmailVerification()` once server is updated. Will return true after 3 seconds
    func debugPollEmailVerification() -> Observable<Bool> {
        return Observable<Int>.interval(1, scheduler: MainScheduler.asyncInstance).map { i -> Bool in
            return i > 3
        }
    }

    /// Polls every second to check if the email has been verified. The sequence will return "true" if the email
    /// is verified, otherwise, "false".
    func pollEmailVerification() -> Observable<Bool> {
        return Observable<Int>.interval(1, scheduler: MainScheduler.asyncInstance).flatMap { [weak self] _ -> Observable<NabuUser> in
            guard let strongSelf = self else {
                return Observable.empty()
            }
            return strongSelf.dataRepository.fetchNabuUser()
                .asObservable()
        }.map { user -> Bool in
            return user.email.verified
        }
    }

    func sendVerificationEmail(to email: EmailAddress) -> Completable {
        guard let guid = appSettings.guid else {
            Logger.shared.warning("Cannot update last-tx-time, guid is nil.")
            return Completable.error(VerifyEmailError.invalidWalletState)
        }
        guard let sharedKey = appSettings.sharedKey else {
            Logger.shared.warning("Cannot update last-tx-time, sharedKey is nil.")
            return Completable.error(VerifyEmailError.invalidWalletState)
        }
        
        return walletSettings.updateEmail(email: email, guid: guid, sharedKey: sharedKey).andThen(
            updateWalletInfo()
        )
    }

    private func updateWalletInfo() -> Completable {
        let sessionTokenSingle = authenticationService.getSessionToken()
        let signedRetailToken = walletService.getSignedRetailToken()
        return Single.zip(sessionTokenSingle, signedRetailToken).flatMap { (sessionToken, signedRetailToken) -> Single<NabuUser> in

            // Error checking
            guard signedRetailToken.success else {
                return Single.error(NetworkError.generic(message: "Signed retail token failed."))
            }

            guard let jwtToken = signedRetailToken.token else {
                return Single.error(NetworkError.generic(message: "Signed retail token is nil."))
            }

            // If all passes, send JWT to Nabu
            let headers = [HttpHeaderField.authorization: sessionToken.token]
            let payload = ["jwt": jwtToken]
            return KYCNetworkRequest.request(
                put: .updateWalletInformation,
                parameters: payload,
                headers: headers,
                type: NabuUser.self
            )
        }.do(onSuccess: { user in
            Logger.shared.debug("""
                Successfully updated user: \(user.personalDetails?.identifier ?? "").
                Email number: \(user.email.address ?? "")
            """)
        }).asCompletable()
    }

}
