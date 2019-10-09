//
//  TransactionDetailViewController+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import PlatformKit

extension TransactionDetailViewController {
    @objc func reportWebViewClick(asset: LegacyAssetType) {
        let asset = AssetType(from: asset)
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Transactions.transactionsItemWebViewClick(asset: asset)
        )
    }
}
