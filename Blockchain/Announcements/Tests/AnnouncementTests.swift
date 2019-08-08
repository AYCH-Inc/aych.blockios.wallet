//
//  AnnouncementTests.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import XCTest

@testable import Blockchain

class AnnouncementTests: XCTestCase {

    // MARK: PAX
    
    func testPaxAnnouncementShows() {
        let cache = MemoryCacheSuite()
        let announcement = PAXAnnouncement(
            dismissRecorder: AnnouncementDismissRecorder(cache: cache),
            dismiss: {},
            approve: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.dismissEntry.isDismissed)
        
        announcement.dismissEntry.markDismissed()
        
        XCTAssertTrue(announcement.dismissEntry.isDismissed)
    }
    
    // MARK: PIT
    
    func testPitLinkingAnnouncementShows() {
        let config = MockFeatureConfigurator(isEnabled: true).configuration(for: .pitAnnouncement)
        let cache = MemoryCacheSuite()
        let announcement = PitLinkingAnnouncement(
            config: config,
            dismissRecorder: AnnouncementDismissRecorder(cache: cache),
            dismiss: {},
            approve: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.dismissEntry.isDismissed)
        
        announcement.dismissEntry.markDismissed()
        
        XCTAssertTrue(announcement.dismissEntry.isDismissed)
    }
}
