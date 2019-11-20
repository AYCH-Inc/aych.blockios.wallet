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
    }
}
