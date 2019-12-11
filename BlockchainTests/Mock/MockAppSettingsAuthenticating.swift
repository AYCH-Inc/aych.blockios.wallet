//
//  MockAppSettingsAuthenticating.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@testable import PlatformKit

class MockAppSettings: ReactiveAppSettingsAuthenticating, AppSettingsAuthenticating, SwipeToReceiveConfiguring {
    @objc var pin: String?
    @objc var pinKey: String?
    @objc var biometryEnabled: Bool
    @objc var passwordPartHash: String?
    @objc var encryptedPinPassword: String?
    @objc var swipeToReceiveEnabled = false
    
    init(pin: String? = nil,
         pinKey: String? = nil,
         biometryEnabled: Bool = false,
         passwordPartHash: String? = nil,
         encryptedPinPassword: String? = nil) {
        self.pin = pin
        self.pinKey = pinKey
        self.biometryEnabled = biometryEnabled
        self.passwordPartHash = passwordPartHash
        self.encryptedPinPassword = encryptedPinPassword
    }
}
