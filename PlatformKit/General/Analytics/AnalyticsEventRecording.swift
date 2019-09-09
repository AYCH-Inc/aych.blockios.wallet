//
//  AnalyticsEventRecording.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol AnalyticsEvent {
    var name: String { get }
    var params: [String: String]? { get }
}

public protocol AnalyticsEventRecording {
    func record(event: AnalyticsEvent)
}

public protocol AnalyticsEventRecordable {
    func use(eventRecorder: AnalyticsEventRecording)
}
