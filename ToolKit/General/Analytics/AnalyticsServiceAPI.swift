//
//  AnalyticsServiceAPI.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol AnalyticsServiceAPI {
    func trackEvent(title: String, parameters: [String: Any]?)
}
