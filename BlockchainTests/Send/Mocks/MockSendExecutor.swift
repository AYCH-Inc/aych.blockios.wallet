//
//  MockSendExecutor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

@testable import Blockchain

final class MockSendExecutor: SendExecuting {
    
    private let expectedResult: Result<Void, Error>
    
    init(expectedResult: Result<Void, Error>) {
        self.expectedResult = expectedResult
    }
    
    func fetchHistoryIfNeeded() {}
    func send(value: CryptoValue, to address: String) -> Single<Void> {
        switch expectedResult {
        case .success:
            return .just(Void())
        case .failure(let error):
            return Single.error(error)
        }
    }
}
