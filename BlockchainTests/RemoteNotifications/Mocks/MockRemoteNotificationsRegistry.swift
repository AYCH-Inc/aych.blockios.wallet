//
//  MockUIApplicationRemoteNotifications.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

final class MockRemoteNotificationsRegistry: UIApplicationRemoteNotificationsAPI {
    
    private(set) var isRegistered = false

    func registerForRemoteNotifications() {
        isRegistered = true
    }
}
