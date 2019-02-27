//
//  AnalyticsService.swift
//  Blockchain
//
//  Created by Roberto Gil Del Sol on 01/11/2018.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Firebase

class AnalyticsService {
    
    static let shared = AnalyticsService()

    typealias AnalyticsParameters = [String: Any]

    // MARK: - Properties
    
    // Enumerates campaigns that can be used in analytics events
    enum Campaigns: String, CaseIterable {
        case sunriver
    }
    
    // MARK: Public Methods
    
    // Simple custom event with no parameters
    func trackEvent(title: String, parameters: AnalyticsParameters? = nil) {
        if !title.isEmpty {
           Analytics.logEvent(title, parameters: parameters)
        }
    }
}
