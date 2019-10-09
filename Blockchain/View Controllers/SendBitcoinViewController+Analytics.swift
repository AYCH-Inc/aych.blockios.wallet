//
//  SendBitcoinViewController+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension SendBitcoinViewController {
    
    private var asset: AssetType {
        return AssetType(from: assetType)
    }
    
    @objc
    func reportPitButtonClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendFormPitButtonClick(asset: asset)
        )
    }
    
    @objc
    func reportFormUseBalanceClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendFormUseBalanceClick(asset: asset)
        )
    }
    
    @objc
    func reportSendFormConfirmClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendFormConfirmClick(asset: asset)
        )
    }

    @objc
    func reportSendFormConfirmSuccess() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendFormConfirmSuccess(asset: asset)
        )
    }
    
    @objc
    func reportSendFormConfirmFailure() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendFormConfirmFailure(asset: asset)
        )
    }
    
    @objc
    func reportSendSummaryConfirmClick() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendSummaryConfirmClick(asset: asset)
        )
    }
    
    @objc
    func reportSendSummaryConfirmSuccess() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendSummaryConfirmSuccess(asset: asset)
        )
    }
    
    @objc
    func reportSendSummaryConfirmFailure() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Send.sendSummaryConfirmFailure(asset: asset)
        )
    }
}
