//
//  KYCTier.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates the different tiers for KYC. A higher tier requires
/// users to provide us with more information about them which
/// qualifies them for higher limits of trading.
///
/// - tier1: the 1st tier requiring the user to only provide basic
///          user information such as name and address.
/// - tier2: the 2nd tier requiring the user to provide additional
///          identity information such as a drivers licence, passport,
//           etc.
public enum KYCTier: String {
    case tier1 = "1"
    case tier2 = "2"
}

public extension KYCTier {
    var headline: String? {
        switch self {
        case .tier1:
            return nil
        case .tier2:
            return LocalizationConstants.KYC.freeCrypto
        }
    }
    
    var tierDescription: String {
        switch self {
        case .tier1:
            return LocalizationConstants.KYC.tierOneVerification
        case .tier2:
            return LocalizationConstants.KYC.tierTwoVerification
        }
    }
    
    var limitDescription: String {
        let symbol = Locale.current.currencySymbol ?? "$"
        let formatter: NumberFormatter = NumberFormatter.localCurrencyFormatterWithGroupingSeparator
        switch self {
        case .tier1:
            let amount = NSNumber(value: 1000)
            return symbol + (formatter.string(from: amount) ?? "1,000")
        case .tier2:
            let amount = NSNumber(value: 25000)
            return symbol + (formatter.string(from: amount) ?? "25,000")
        }
    }
    
    var limitTimeframe: String {
        switch self {
        case .tier1:
            return LocalizationConstants.KYC.annualSwapLimit
        case .tier2:
            return LocalizationConstants.KYC.dailySwapLimit
        }
    }
    
    var duration: String {
        switch self {
        case .tier1:
            return LocalizationConstants.KYC.takesThreeMinutes
        case .tier2:
            return LocalizationConstants.KYC.takesTenMinutes
        }
    }
}
