//
//  AnalyticsEvents+SideMenu.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/26/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//
import PlatformKit

extension AnalyticsEvents {
    struct SideMenu {
        struct ItemTapped: AnalyticsEvent {
            let item: SideMenuItem

            let params: [String: String]? = nil

            var name: String {
                return "side_nav_\(item.analyticsKey)"
            }
        }
    }
}
