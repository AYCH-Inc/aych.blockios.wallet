//
//  TransactionDetailNavigationController+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import NetworkKit
import PlatformKit

extension TransactionDetailNavigationController {
    @objc func reportShare(asset: LegacyAssetType) {
        let asset = AssetType(from: asset)
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Transactions.transactionsItemShareClick(asset: asset)
        )
    }
}
