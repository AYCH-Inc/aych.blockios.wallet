//
//  SettingsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public protocol SettingsServiceAPI: class {
    var state: Observable<SettingsService.CalculationState> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
    func refresh()
}

public protocol LastTransactionSettingsUpdateServiceAPI: class {
    func updateLastTransaction() -> Completable
}

public protocol EmailNotificationSettingsServiceAPI: SettingsServiceAPI {
    func emailNotifications(enabled: Bool) -> Completable
}
