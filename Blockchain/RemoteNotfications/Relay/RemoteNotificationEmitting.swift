//
//  RemoteNotificationEmitting.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Entry point for observing any incoming notification within the app
protocol RemoteNotificationEmitting: class {
    var notification: Observable<RemoteNotification.NotificationType> { get }
}
