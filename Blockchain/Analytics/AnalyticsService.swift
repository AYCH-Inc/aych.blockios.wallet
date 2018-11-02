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
    
    // MARK: - Properties
    
    // Enumerates campaigns that can be used in analytics events
    enum Campaigns: String, CaseIterable {
        case sunriver
    }
    
    // MARK: Public Methods
    
    func trackEvent(title: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title)",
            AnalyticsParameterItemName: title,
            ])
    }
}
