//
//  MockBlockchainSettings.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockBlockchainSettingsApp: BlockchainSettings.App {
    var mockDidAttemptToRouteForAirdrop: Bool = false
    var mockDidTapOnAirdropDeepLink: Bool = false
    var mockGuid: String?
    var mockSharedKey: String?

    override init() {
        super.init()
    }

    override var guid: String? {
        get {
            return mockGuid
        }
        set {
            mockGuid = newValue
        }
    }

    override var sharedKey: String? {
        get {
            return mockSharedKey
        }
        set {
            mockSharedKey = newValue
        }
    }

    override var didTapOnAirdropDeepLink: Bool {
        get {
            return mockDidTapOnAirdropDeepLink
        }
        set {
            mockDidTapOnAirdropDeepLink = newValue
        }
    }

    override var didAttemptToRouteForAirdrop: Bool {
        get {
            return mockDidAttemptToRouteForAirdrop
        }
        set {
            mockDidAttemptToRouteForAirdrop = newValue
        }
    }
}
