//
//  SettingsClientAPI.swift
//  PlatformKit
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// TODO: Make `SettingsClientAPI` private when all information services are
/// provided by `UserInformationServiceProvider`.

/// Protocol definition for interacting with the `WalletSettings` object.
public protocol SettingsClientAPI: class {
    
    /// Fetches the wallet settings from the backend.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Single` that wraps a `SettingsResponse`.
    func settings(by guid: String, sharedKey: String) -> Single<SettingsResponse>
    
    /// Updates the user's email.
    /// - Parameter email: The email value.
    /// - Parameter context: The context in which the update is happening.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func update(email: String, context: FlowContext?, guid: String, sharedKey: String) -> Completable

    /// Updates the last transaction time performed by this wallet.
    ///
    /// This method should be invoked when:
    ///   - the user buys crypto using fiat
    ///   - the user sends crypto
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func updateLastTransactionTime(guid: String, sharedKey: String) -> Completable
    
    func emailNotifications(enabled: Bool, guid: String, sharedKey: String) -> Completable
}
