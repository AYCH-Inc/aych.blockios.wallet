//
//  ExternalNotificationServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import RxSwift
import PlatformKit

/// A class that is a gateway to external notification service functionality
final class ExternalNotificationServiceProvider: ExternalNotificationProviding {
    
    // MARK: - Properties
    
    /// A `Single` that streams the token value if exist and not empty or `nil`.
    /// Throws an error (`RemoteNotificationTokenFetchError`) in case the service has failed or if the token came out empty.
    var token: Single<String> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.tokenFetcher.instanceID { result in
                    observer(result.singleEvent)
                }
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    private let tokenFetcher: RemoteNotificationTokenFetching
    private let messagingService: FCMServiceAPI
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(tokenFetcher: RemoteNotificationTokenFetching = InstanceID.instanceID(),
         messagingService: FCMServiceAPI = Messaging.messaging()) {
        self.tokenFetcher = tokenFetcher
        self.messagingService = messagingService
    }
    
    /// Subscribes to a given topic so the client will be able to receive notifications for it.
    /// - Parameter topic: the topic that the client should subscribe to.
    /// - Returns: A `Single` acknowledges the subscription.
    func subscribe(to topic: RemoteNotification.Topic) -> Single<Void> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.messagingService.subscribe(toTopic: topic.rawValue) { error in
                    if let error = error {
                        observer(.error(error))
                    } else {
                        observer(.success(()))
                    }
                }
                return Disposables.create()
        }
    }
    
    // Let the messaging service know about the new token
    func didReceiveNewApnsToken(token: Data) {
        messagingService.apnsToken = token
    }
}
