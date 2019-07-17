//
//  AuthenticationManagerProtocol.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 The type alias for the closure used in:
 * `authenticateUsingBiometrics(andReply:)`
 */
typealias BiometricsAuthHandler = (_ authenticated: Bool, _ error: AuthenticationError?) -> Void

protocol AuthenticationManagerProtocol: class {
    var canAuthenticateUsingBiometry: Bool { get }
    var configuredBiometricsType: BiometricsType { get }
    var biometricsConfigurationStatus: BiometricsStatus { get }
    func authenticateUsingBiometrics(andReply handler: @escaping BiometricsAuthHandler)
}
