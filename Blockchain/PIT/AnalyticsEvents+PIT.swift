//
//  AnalyticsEvents+PIT.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/26/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension AnalyticsEvents {
    struct PIT {
        struct AnnouncementTapped: AnalyticsEvent {
            let name = "pit_announcement_tapped"
            let params: [String: String]? = nil
        }

        struct ConnectNowTapped: AnalyticsEvent {
            let name = "pit_connect_now_tapped"
            let params: [String: String]? = nil
        }

        struct LearnMoreTapped: AnalyticsEvent {
            let name = "pit_learn_more_tapped"
            let params: [String: String]? = nil
        }
    }
}
