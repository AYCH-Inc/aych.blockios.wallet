//
//  MockRemoteNotificationRelay.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

@testable import Blockchain

final class MockRemoteNotificationRelay: RemoteNotificationEmitting {
    let relay = PublishRelay<RemoteNotification.NotificationType>()
    var notification: Observable<RemoteNotification.NotificationType> {
        return relay.asObservable()
    }
}
