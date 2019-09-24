//
//  APIClientMock.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
@testable import BitcoinKit

class APIClientMock: APIClientAPI {
    var lastUnspentOutputAddresses: [String]?
    var unspentOutputsValue: Single<UnspentOutputsResponse> = Single.error(NSError())
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse> {
        lastUnspentOutputAddresses = addresses
        return unspentOutputsValue
    }
}
