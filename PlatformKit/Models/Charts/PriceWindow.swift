//
//  PriceWindow.swift
//  PlatformKit
//
//  Created by AlexM on 9/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum PriceWindow {
    public typealias Start = Date
    public typealias Timeline = TimeInterval
    public typealias CurrencyCode = String
    
    public enum TimelineInterval {
        case fifteenMinutes
        case oneHour
        case twoHours
        case oneDay
        case fiveDays
    }
    
    case day(TimelineInterval?)
    case week(TimelineInterval?)
    case month(TimelineInterval?)
    case year(TimelineInterval?)
    case all(TimelineInterval?)
}

extension PriceWindow {
    var timelineInterval: TimelineInterval {
        switch self {
        case .all(let interval):
            return interval ?? .fiveDays
        case .day(let interval):
            return interval ?? .fifteenMinutes
        case .week(let interval):
            return interval ?? .oneHour
        case .year(let interval):
            return interval ?? .oneDay
        case .month(let interval):
            return interval ?? .twoHours
        }
    }
}

public extension PriceWindow {
    var scale: Int {
        return Int(timelineInterval.value)
    }
}

public extension PriceWindow.TimelineInterval {
    var value: TimeInterval {
        switch self {
        case .fifteenMinutes:
            return 900
        case .oneHour:
            return 3600
        case .twoHours:
            return 7200
        case .oneDay:
            return 86400
        case .fiveDays:
            return 432000
        }
    }
}

public extension CryptoCurrency {
    var maxStartDate: TimeInterval {
        switch self {
        case .bitcoin:
            return 1282089600
        case .bitcoinCash:
            return 1500854400
        case .ethereum:
            return 1438992000
        case .pax:
            return 1555060318
        case .stellar:
            return 1525716000
        }
    }
}
