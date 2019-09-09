//
//  AnalyticsEventRecorder.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class AnalyticsEventRecorder: AnalyticsEventRecording {

    private let analyticsService: AnalyticsServiceAPI

    public init(analyticsService: AnalyticsServiceAPI) {
        self.analyticsService = analyticsService
    }

    public func record(event: AnalyticsEvent) {
        analyticsService.trackEvent(title: event.name, parameters: event.params)
    }

}
