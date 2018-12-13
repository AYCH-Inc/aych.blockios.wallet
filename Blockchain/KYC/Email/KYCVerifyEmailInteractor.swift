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
    private let walletSettings: WalletSettingsAPI
    private let walletService: WalletService

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        walletSettings: WalletSettingsAPI = WalletSettingsService(),
        walletService: WalletService = WalletService.shared
    ) {
        self.appSettings = appSettings
        self.authenticationService = authenticationService
        self.walletSettings = walletSettings
        self.walletService = walletService
    }

    func sendVerificationEmail(to email: Email) -> Completable {
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
                Email number: \(user.personalDetails?.email ?? "")
            """)
        }).asCompletable()
    }

}
