//
//  SettingsSelectorTableViewController+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import NetworkKit
import PlatformKit

extension SettingsSelectorTableViewController {
    @objc
    func reportSelectedCurrency(currency: String?) {
        guard let currency = currency else { return }
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Settings.settingsCurrencySelected(currency: currency)
        )
    }
}
