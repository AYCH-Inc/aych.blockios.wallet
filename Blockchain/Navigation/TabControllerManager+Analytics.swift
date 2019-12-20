//
//  TabControllerManager+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import PlatformUIKit

extension TabControllerManager {
    
    @objc
    func recordSwapTabItemClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Swap.swapTabItemClick
        )
    }
    
    @objc
    func recordSendTabItemClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendTabItemClick
        )
    }
    
    @objc
    func recordActivityTabItemClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Transactions.transactionsTabItemClick
        )
    }
    
    @objc
    func recordRequestTabItemClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Request.requestTabItemClick
        )
    }
}
