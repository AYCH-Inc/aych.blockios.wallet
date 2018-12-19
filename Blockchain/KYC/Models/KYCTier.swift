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
public enum KYCTier: Int, Codable {
    case tier0 = 0
    case tier1 = 1
    case tier2 = 2
}

public extension KYCTier {
    var headline: String? {
        switch self {
        case .tier0:
            return nil
        case .tier1:
            return nil
        case .tier2:
            return LocalizationConstants.KYC.freeCrypto
        }
    }
    
    var tierDescription: String {
        switch self {
        case .tier0:
            return "Tier Zero Verification"
        case .tier1:
            return LocalizationConstants.KYC.tierOneVerification
        case .tier2:
            return LocalizationConstants.KYC.tierTwoVerification
        }
    }
    
    var requirementsDescription: String {
        switch self {
        case .tier0:
            return ""
        case .tier1:
            return LocalizationConstants.KYC.tierOneRequirements
        case .tier2:
            return LocalizationConstants.KYC.tierTwoRequirements
        }
    }
    
    var limitTimeframe: String {
        switch self {
        case .tier0:
            return "locked"
        case .tier1:
            return LocalizationConstants.KYC.annualSwapLimit
        case .tier2:
            return LocalizationConstants.KYC.dailySwapLimit
        }
    }
    
    var duration: String {
        switch self {
        case .tier0:
            return "0 minutes"
        case .tier1:
            return LocalizationConstants.KYC.takesThreeMinutes
        case .tier2:
            return LocalizationConstants.KYC.takesTenMinutes
        }
    }
}
