//
//  AnalyticsEvents+Onboarding.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

@objc class CreateWalletAnalyticsEvent: NSObject, ObjcAnalyticsEvent {
    let name = "wallet_creation"
    let params: [String: String]? = nil
}

extension AnalyticsEvents {
    struct Onboarding {
        struct ManualLogin: AnalyticsEvent {
            let name = "wallet_manual_login"
            let params: [String: String]? = nil
        }
        struct AutoPairing: AnalyticsEvent {
            let name = "wallet_auto_pairing"
            let params: [String: String]? = nil
        }
    }
}

