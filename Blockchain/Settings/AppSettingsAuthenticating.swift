//
//  AppSettingsProtocol.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Serves any authentication logic that should be extracted from the app settings
@objc
protocol AppSettingsAuthenticating: class {
    @objc var pin: String? { get set }
    @objc var pinKey: String? { get set }
    @objc var biometryEnabled: Bool { get set }
    @objc var passwordPartHash: String? { get set }
    @objc var encryptedPinPassword: String? { get set }
}
