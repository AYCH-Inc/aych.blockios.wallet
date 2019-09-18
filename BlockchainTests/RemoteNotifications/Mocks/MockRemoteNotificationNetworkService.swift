//
//  MockRemoteNotificationNetworkService.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class MockRemoteNotificationNetworkService: RemoteNotificationNetworkServicing {
    let expectedResult: Result<Void, RemoteNotificationNetworkService.PushNotificationError>
    
    init(expectedResult: Result<Void, RemoteNotificationNetworkService.PushNotificationError>) {
        self.expectedResult = expectedResult
    }
    
    func register(with token: String,
                  using credentialsProvider: WalletCredentialsProviding) -> Single<Void> {
        return expectedResult.single
    }
}
