//
//  MockAuthenticationManager.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class MockBiometryProvider: BiometryProviding {
        
    let canAuthenticate: Result<Void, Biometry.EvaluationError>
    var configuredType: Biometry.BiometryType
    let configurationStatus: Biometry.Status

    private let authenticatesSuccessfully: Bool
    
    init(authenticatesSuccessfully: Bool,
         canAuthenticate: Result<Void, Biometry.EvaluationError>,
         configuredType: Biometry.BiometryType,
         configurationStatus: Biometry.Status) {
        self.authenticatesSuccessfully = authenticatesSuccessfully
        self.canAuthenticate = canAuthenticate
        self.configuredType = configuredType
        self.configurationStatus = configurationStatus
    }
    
    func authenticate(reason: Biometry.Reason) -> Single<Void> {
        switch canAuthenticate {
        case .success:
            return .just(())
        case .failure(let error):
            return .error(error)
        }
    }
}
