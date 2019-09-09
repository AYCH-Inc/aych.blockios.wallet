//
//  BridgeAnalyticsRecorder.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

@objc protocol ObjcAnalyticsEvent {
    var name: String { get }
    var params: [String: String]? { get }
}

// Obj-C Bridge to AnalyticsEventRecording. Deprecate this once obj-c callers are updated to Swift
@objc class BridgeAnalyticsRecorder : NSObject {

    private let recorder: AnalyticsServiceAPI

    override init() {
        self.recorder = AnalyticsService.shared
        super.init()
    }

    @objc public func record(event: ObjcAnalyticsEvent) {
        recorder.trackEvent(title: event.name, parameters: event.params)
    }
}
