//
//  UserInformationServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class UserInformationServiceProvider: UserInformationServiceProviding {
    
    /// The default container
    static let `default` = UserInformationServiceProvider()
    
    /// Persistent service that has access to the general wallet settings
    let settings: SettingsServiceAPI & EmailSettingsServiceAPI & LastTransactionSettingsUpdateServiceAPI & EmailNotificationSettingsServiceAPI
    
    /// Computes and returns an email verification service API
    var emailVerification: EmailVerificationServiceAPI {
        return EmailVerificationService(
            authenticationService: NabuAuthenticationService.shared, /// TODO: Move it to `PlatformKit`
            settingsService: settings
        )
    }
    
    init(repository: WalletRepositoryAPI = WalletManager.shared.repository,
         settingsClient: SettingsClientAPI = SettingsClient()) {
        settings = SettingsService(
            client: settingsClient,
            credentialsRepository: repository
        )
    }
}
