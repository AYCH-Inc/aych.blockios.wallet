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

final class AnnouncementTests: XCTestCase {

    // MARK: PAX
    
    func testPaxAnnouncementShows() {
        let cache = MemoryCacheSuite()
        let announcement = PAXAnnouncement(
            hasTransactions: false,
            cacheSuite: cache,
            dismiss: {},
            action: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.isDismissed)
        
        announcement.markRemoved()
        
        XCTAssertFalse(announcement.shouldShow)
        XCTAssertTrue(announcement.isDismissed)
    }
    
    // MARK: PIT
    
    func testPitLinkingAnnouncementShows() {
        let cache = MemoryCacheSuite()
        let announcement = PITLinkingAnnouncement(
            shouldShowPitAnnouncement: true,
            variant: .variantA,
            cacheSuite: cache,
            variantFetcher: MockFeatureFetcher(),
            dismiss: {},
            action: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.isDismissed)
        
        announcement.markRemoved()
        
        XCTAssertFalse(announcement.shouldShow)
        XCTAssertTrue(announcement.isDismissed)
    }
    
    func testAnnouncementQueue() {
        let cache = MemoryCacheSuite()
        let oneTimeAnnouncements = [MockOneTimeAnnouncement(type: .pax, cacheSuite: cache, dismiss: {}),
                                    MockOneTimeAnnouncement(type: .pitLinking, cacheSuite: cache, dismiss: {})]
        oneTimeAnnouncements[1].markRemoved()
        XCTAssertFalse(oneTimeAnnouncements[0].isDismissed)
        XCTAssertTrue(oneTimeAnnouncements[1].isDismissed)
    }
}
