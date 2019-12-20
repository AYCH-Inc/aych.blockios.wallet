//
//  SettingsChangePasswordViewController+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

extension SettingsChangePasswordViewController {
    @objc
    func reportChangePasswordSuccess() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Settings.settingsPasswordSelected
        )
    }
}
