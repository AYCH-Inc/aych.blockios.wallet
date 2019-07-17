//
//  MockAuthenticationManager.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockAuthenticationManager: AuthenticationManagerProtocol {
    
    struct MockBiometricsAuthError: Error {}
    
    let canAuthenticateUsingBiometry: Bool
    let configuredBiometricsType: BiometricsType
    let biometricsConfigurationStatus: BiometricsStatus
    
    private let authenticatesSuccessfully: Bool
    
    init(authenticatesSuccessfully: Bool,
         canAuthenticateUsingBiometry: Bool,
         configuredBiometricsType: BiometricsType,
         biometricsConfigurationStatus: BiometricsStatus) {
        self.authenticatesSuccessfully = authenticatesSuccessfully
        self.canAuthenticateUsingBiometry = canAuthenticateUsingBiometry
        self.configuredBiometricsType = configuredBiometricsType
        self.biometricsConfigurationStatus = biometricsConfigurationStatus
    }
    
    func authenticateUsingBiometrics(andReply handler: BiometricsAuthHandler) {
        if canAuthenticateUsingBiometry {
            handler(authenticatesSuccessfully, nil)
        } else {
            let error = AuthenticationError(code: 0, description: "")
            handler(authenticatesSuccessfully, error)
        }
    }
}
