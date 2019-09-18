//
//  MockExternalNotificationServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

/// A class that is a gateway to external notification service functionality
final class MockExternalNotificationServiceProvider: ExternalNotificationProviding {
    
    struct FakeError: Error {
        let info: String
    }
    
    var token: Single<String> {
        return expectedTokenResult.single
    }
    
    private let expectedTokenResult: Result<String, FakeError>
    private let expectedTopicSubscriptionResult: Result<Void, FakeError>
    
    private(set) var topics: [RemoteNotification.Topic] = []
    
    init(expectedTokenResult: Result<String, FakeError>,
         expectedTopicSubscriptionResult: Result<Void, FakeError>) {
        self.expectedTokenResult = expectedTokenResult
        self.expectedTopicSubscriptionResult = expectedTopicSubscriptionResult
    }
    
    func didReceiveNewApnsToken(token: Data) {}
    
    func subscribe(to topic: RemoteNotification.Topic) -> Single<Void> {
        switch expectedTopicSubscriptionResult {
        case .success:
            topics.append(topic)
        case .failure:
            break
        }
        return expectedTopicSubscriptionResult.single
    }
}
