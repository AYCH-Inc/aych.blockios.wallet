//
//  LocalizationConstants+TimeUnits.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 06/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension LocalizationConstants {
    struct TimeUnit {
        struct Singular {
            static let hour = NSLocalizedString(
                "hr",
                comment: "Dashboard: balance component - hourly price movement"
            )
            static let day = NSLocalizedString(
                "day",
                comment: "Dashboard: balance component - daily price movement"
            )
            static let week = NSLocalizedString(
                "week",
                comment: "Dashboard: balance component - weekly price movement"
            )
            static let month = NSLocalizedString(
                "month",
                comment: "Dashboard: balance component - monthly price movement"
            )
            static let year = NSLocalizedString(
                "year",
                comment: "Dashboard: balance component - years price movement"
            )
        }
        
        struct Plural {
            static let hours = NSLocalizedString(
                "hrs",
                comment: "Dashboard: balance component - hourly price movement"
            )
            static let days = NSLocalizedString(
                "days",
                comment: "Dashboard: balance component - daily price movement"
            )
            static let weeks = NSLocalizedString(
                "weeks",
                comment: "Dashboard: balance component - weekly price movement"
            )
            static let months = NSLocalizedString(
                "months",
                comment: "Dashboard: balance component - monthly price movement"
            )
            static let years = NSLocalizedString(
                "years",
                comment: "Dashboard: balance component - years price movement"
            )
            static let allTime = NSLocalizedString(
                "All Time",
                comment: "Dashboard: balance component - years price movement"
            )
        }
    }
}
