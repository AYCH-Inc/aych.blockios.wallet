//
//  MockWalletSettingsService.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 11/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import XCTest

class MockWalletSettingsService: WalletSettingsAPI {
    var didCallFetchSettings: XCTestExpectation?
    var didCallUpdateSettings: XCTestExpectation?
    var didCallUpdateLastTxTime: XCTestExpectation?

    func fetchSettings(guid: String, sharedKey: String) -> Single<WalletSettings> {
        didCallFetchSettings?.fulfill()
        return Single.never()
    }

    func updateSettings(
        method: WalletSettingsApiMethod,
        guid: String,
        sharedKey: String,
        payload: String,
        context: ContextParameter?
    ) -> Completable {
        didCallUpdateSettings?.fulfill()
        return Completable.empty()
    }

    /// Updates the last transaction time performed by this wallet. This method should be invoked when:
    ///   - the user buys crypto using fiat
    ///   - the user sends crypto
    func updateLastTxTimeToCurrentTime(guid: String, sharedKey: String) -> Completable {
        didCallUpdateLastTxTime?.fulfill()
        return Completable.empty()
    }

    func updateEmail(email: String, guid: String, sharedKey: String, context: ContextParameter?) -> Completable {
        return Completable.empty()
    }
}
