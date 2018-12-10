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
