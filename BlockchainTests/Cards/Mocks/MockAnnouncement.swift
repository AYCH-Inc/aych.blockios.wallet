//
//  MockAnnouncement.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 29/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit
import RxSwift

@testable import Blockchain

struct MockOneTimeAnnouncement: OneTimeAnnouncement {
    
    var viewModel: AnnouncementCardViewModel {
        fatalError("\(#function) was not implemented")
    }
    
    var shouldShow: Bool {
        return !isDismissed
    }
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let type: AnnouncementType
    let analyticsRecorder: AnalyticsEventRecording
    
    init(type: AnnouncementType,
         cacheSuite: CacheSuite,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         dismiss: @escaping CardAnnouncementAction) {
        self.type = type
        recorder = AnnouncementRecorder(cache: cacheSuite)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
    }
}
