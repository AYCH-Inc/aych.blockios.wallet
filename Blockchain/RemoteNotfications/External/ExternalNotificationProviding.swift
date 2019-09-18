//
//  ExternalNotificationServicing.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Aggregrates any external service notification logic
protocol ExternalNotificationProviding: class {
    var token: Single<String> { get }
    func didReceiveNewApnsToken(token: Data)
    func subscribe(to topic: RemoteNotification.Topic) -> Single<Void>
}
