//
//  WalletSettingsAPI.swift
//  PlatformKit
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for interacting with the `WalletSettings` object.
public protocol WalletSettingsAPI {

    func fetchSettings(guid: String, sharedKey: String) -> Single<WalletSettings>

    func updateSettings(
        method: WalletSettingsApiMethod,
        guid: String,
        sharedKey: String,
        payload: String
    ) -> Completable
}
