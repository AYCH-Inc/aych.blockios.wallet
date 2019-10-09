//
//  BCCreateWalletView+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension BCCreateWalletView {
    
    @objc
    func reportCreateWallet() {
        AnalyticsEventRecorder.shared.record(
            event: AnalyticsEvents.Onboarding.walletCreation
        )
    }
}


