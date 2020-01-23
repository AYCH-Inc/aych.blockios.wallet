//
//  FlowContext.swift
//  PlatformKit
//
//  Created by Daniel Huri on 24/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Signifies the context of the flow
/// Typically used to report the flow in which something has happened
public enum FlowContext: String {
    case exchangeSignup = "PIT_SIGNUP"
    case kyc = "KYC"
    case settings = "SETTINGS"
}
