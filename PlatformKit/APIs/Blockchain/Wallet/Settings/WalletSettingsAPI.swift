//
//  WalletSettingsAPI.swift
//  PlatformKit
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public enum ContextParameter: String {
    case pitSignup = "PIT_SIGNUP"
    case kyc = "KYC"
    case settings = "SETTINGS"
}

/// Protocol definition for interacting with the `WalletSettings` object.
public protocol WalletSettingsAPI {

    func fetchSettings(guid: String, sharedKey: String) -> Single<WalletSettings>

    func updateSettings(
        method: WalletSettingsApiMethod,
        guid: String,
        sharedKey: String,
        payload: String,
        context: ContextParameter?
    ) -> Completable

    /// Updates the last transaction time performed by this wallet. This method should be invoked when:
    ///   - the user buys crypto using fiat
    ///   - the user sends crypto
    func updateLastTxTimeToCurrentTime(guid: String, sharedKey: String) -> Completable

    /// Updates the users email address in this wallet.
    func updateEmail(email: String, guid: String, sharedKey: String, context: ContextParameter?) -> Completable
}
