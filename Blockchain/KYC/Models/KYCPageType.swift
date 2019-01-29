//
//  KYCPage.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCPageType: Int {
    // Need to set the first enumeration as 1. The order of these enums also matter
    // since KycSettings.latestKycPage will look at the rawValue of the enum when
    // the latestKycPage is set.
    case welcome = 1
    case enterEmail
    case confirmEmail
    case country
    case states
    case profile
    case address
    case tier1ForcedTier2
    case enterPhone
    case confirmPhone
    case verifyIdentity
    case resubmitIdentity
    case applicationComplete
    case accountStatus
}
