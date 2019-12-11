//
//  MockPinService.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

@testable import PlatformKit

struct MockPinClient: PinClientAPI {
    private var response: PinStoreResponse {
        return PinStoreResponse(statusCode: statusCode,
                                error: error,
                                pinDecryptionValue: "pin decryption value",
                                key: "key",
                                value: "value")
    }
    
    private let statusCode: PinStoreResponse.StatusCode?
    private let error: String?
    
    init(statusCode: PinStoreResponse.StatusCode?,
         error: String? = nil) {
        self.statusCode = statusCode
        self.error = error
    }
    
    func create(pinPayload: PinPayload) -> Single<PinStoreResponse> {
        return .just(response)
    }
    
    func validate(pinPayload: PinPayload) -> Single<PinStoreResponse> {
        return .just(response)
    }
}
