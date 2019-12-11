//
//  MockFirebaseInstanceID.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain

final class MockFirebaseInstanceID: RemoteNotificationTokenFetching {
    
    private let expectedResult: RemoteNotificationTokenFetchResult
    
    init(expectedResult: RemoteNotificationTokenFetchResult) {
        self.expectedResult = expectedResult
    }
    func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void) {
        handler(expectedResult)
    }
}
