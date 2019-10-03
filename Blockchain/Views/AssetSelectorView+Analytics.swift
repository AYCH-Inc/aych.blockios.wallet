//
//  AssetSelectorView+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension AssetSelectorView {
    
    @objc
    func reportOpen() {
        let asset = AssetType(from: selectedAsset)
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.AssetSelection.assetSelectorOpen(asset: asset)
        )
    }
    
    @objc
    func reportClose() {
        let asset = AssetType(from: selectedAsset)
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.AssetSelection.assetSelectorClose(asset: asset)
        )
    }
}
