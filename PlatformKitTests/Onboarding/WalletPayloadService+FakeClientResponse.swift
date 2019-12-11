//
//  WalletPayloadService+FakeClientResponse.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 10/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
@testable import PlatformKit

extension WalletPayloadClient.Response {
    static func fake(
        guid: String = "123-abc-456-def-789-ghi",
        authenticatorType: AuthenticatorType = .standard,
        language: String = "en",
        serverTime: TimeInterval = Date().timeIntervalSince1970,
        payload: String? = "{\"pbkdf2_iterations\":1,\"version\":3,\"payload\":\"payload-for-wallet\"}",
        shouldSyncPubkeys: Bool = false
    ) -> WalletPayloadClient.Response {
        return WalletPayloadClient.Response(
            guid: guid,
            authType: authenticatorType.rawValue,
            language: language,
            serverTime: serverTime,
            payload: payload,
            shouldSyncPubkeys: shouldSyncPubkeys
        )
    }
}
