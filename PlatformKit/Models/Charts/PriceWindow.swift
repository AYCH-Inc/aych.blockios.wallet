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
    
    public struct Parameters {
        public let currency: CryptoCurrency
        public let code: String
        
        public init(currency: CryptoCurrency, code: String) {
            self.currency = currency
            self.code = code
        }
    }
    
    enum TimelineInterval {
        case fifteenMinutes
        case oneHour
        case twoHours
        case oneDay
        case fiveDays
        case custom(TimeInterval)
    }
    
    case day(Parameters)
    case week(Parameters)
    case month(Parameters)
    case year(Parameters)
    case all(Parameters)
    case custom(Parameters, Start, Timeline)
}

extension PriceWindow {
    var timelineInterval: TimelineInterval {
        switch self {
        case .all:
            return .fiveDays
        case .day:
            return .fifteenMinutes
        case .week:
            return .oneHour
        case .year:
            return .oneDay
        case .month:
            return .twoHours
        case .custom(_, _, let timeline):
            return .custom(timeline)
        }
    }
}

public extension PriceWindow {
    var scale: Int {
        return Int(timelineInterval.value)
    }
    
    var code: String {
        switch self {
        case .all(let parameters):
            return parameters.code
        case .year(let parameters):
            return parameters.code
        case .month(let parameters):
            return parameters.code
        case .week(let parameters):
            return parameters.code
        case .day(let parameters):
            return parameters.code
        case .custom(let parameters, _, _):
            return parameters.code
        }
    }
    
    var symbol: String {
        switch self {
        case .all(let parameters):
            return parameters.currency.symbol.lowercased()
        case .year(let parameters):
            return parameters.currency.symbol.lowercased()
        case .month(let parameters):
            return parameters.currency.symbol.lowercased()
        case .week(let parameters):
            return parameters.currency.symbol.lowercased()
        case .day(let parameters):
            return parameters.currency.symbol.lowercased()
        case .custom(let parameters, _, _):
            return parameters.currency.symbol.lowercased()
        }
    }
    
    var currency: CryptoCurrency {
        switch self {
        case .all(let parameters):
            return parameters.currency
        case .year(let parameters):
            return parameters.currency
        case .month(let parameters):
            return parameters.currency
        case .week(let parameters):
            return parameters.currency
        case .day(let parameters):
            return parameters.currency
        case .custom(let parameters, _, _):
            return parameters.currency
        }
    }
    
    var start: Int {
        switch self {
        case .all(let parameters):
            return Int(parameters.currency.maxStartDate)
        case .year:
            let timeInterval = Date().addingTimeInterval(-31536000).timeIntervalSince1970
            return Int(timeInterval)
        case .month:
            let timeInterval = Date().addingTimeInterval(-2592000).timeIntervalSince1970
            return Int(timeInterval)
        case .week:
            let timeInterval = Date().addingTimeInterval(-604800).timeIntervalSince1970
            return Int(timeInterval)
        case .day:
            let timeInterval = Date().addingTimeInterval(-86400).timeIntervalSince1970
            return Int(timeInterval)
        case .custom(_, let start, _):
            let timeInterval = Date().addingTimeInterval(-abs(start.timeIntervalSince1970)).timeIntervalSince1970
            return Int(timeInterval)
        }
    }
}

private extension PriceWindow.TimelineInterval {
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
        case .custom(let value):
            return value
        }
    }
}

private extension CryptoCurrency {
    var maxStartDate: TimeInterval {
        switch self {
        case .bitcoin:
            return 1282089600.0
        case .bitcoinCash:
            return 1500854400.0
        case .ethereum:
            return 1438992000.0
        case .pax:
            return 1555060318.0
        case .stellar:
            return 1525716000.0
        }
    }
}
