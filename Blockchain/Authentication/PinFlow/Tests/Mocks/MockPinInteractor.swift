//
//  MockPinInteractor.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class MockPinInteractor: PinInteracting {
    
    var hasLogoutAttempted = false
    let expectedPinDecryptionKey: String
    let expectedError: PinError?
    
    init(expectedError: PinError? = nil,
         expectedPinDecryptionKey: String = "expected pin decryption key") {
        self.expectedError = expectedError
        self.expectedPinDecryptionKey = expectedPinDecryptionKey
    }
    
    func create(using payload: PinPayload) -> Completable {
        if let expectedError = expectedError {
            return Completable.error(expectedError)
        }
        return Completable.empty()
    }
    
    func validate(using payload: PinPayload) -> Single<String> {
        if let expectedError = expectedError {
            return Single.error(expectedError)
        }
        return Single.just(expectedPinDecryptionKey)
    }
    
    func persist(pin: Pin) {}
}
