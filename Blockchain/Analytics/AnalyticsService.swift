//
//  AnalyticsService.swift
//  Blockchain
//
//  Created by Roberto Gil Del Sol on 01/11/2018.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Firebase
import ToolKit
import PlatformKit

class AnalyticsService: AnalyticsServiceAPI {
    
    // Enumerates campaigns that can be used in analytics events
    enum Campaigns: String, CaseIterable {
        case sunriver
    }
    
    private struct FirebaseConstants {
        
        struct MaxLength {
            
            static let key = 40
            static let value = 100
        }
        
        static let reservedKeys = [
            "ad_activeview",
            "ad_click",
            "ad_exposure",
            "ad_impression",
            "ad_query",
            "adunit_exposure",
            "app_clear_data",
            "app_remove",
            "app_update",
            "error",
            "first_open",
            "in_app_purchase",
            "notification_dismiss",
            "notification_foreground",
            "notification_open",
            "notification_receive",
            "os_update",
            "screen_view",
            "session_start",
            "user_engagement"
        ]
    }
    
    static let shared = AnalyticsService()
    
    // MARK: - Properties
    
    private let queue = DispatchQueue(label: "AnalyticsService", qos: .background)
    
    // MARK: Public Methods
    
    // Simple custom event with no parameters
    func trackEvent(title: String, parameters: [String: Any]? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard !title.isEmpty, !self.isReservedKey(title) else { return }
            let title = String(title.prefix(FirebaseConstants.MaxLength.key))
            guard let parameters = parameters else {
                Analytics.logEvent(title, parameters: nil)
                return
            }
            let params = parameters
                .mapValues { value -> Any in
                    guard let valueString = value as? String else {
                        return value
                    }
                    return valueString.prefix(FirebaseConstants.MaxLength.value)
                }
            Analytics.logEvent(title, parameters: params)
        }
    }
    
    // MARK: Private methods
    
    private func isReservedKey(_ key: String) -> Bool {
        return FirebaseConstants.reservedKeys.contains(key)
    }
}

extension AnalyticsEventRecorder {
    static let shared = AnalyticsEventRecorder(analyticsService: AnalyticsService.shared)
}
