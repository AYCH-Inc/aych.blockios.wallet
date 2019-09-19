//
//  AnnouncementRecorderTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain
@testable import PlatformKit

extension AnnouncementRecord.DisplayState {
    var isHidden: Bool {
        switch self {
        case .show, .conditional:
            return false
        case .hide:
            return true
        }
    }
    
    var isShown: Bool {
        switch self {
        case .hide, .conditional:
            return false
        case .show:
            return true
        }
    }
    
    var isConditional: Bool {
        switch self {
        case .conditional:
            return true
        case .show, .hide:
            return false
        }
    }
}

final class AnnouncementRecorderTests: XCTestCase {

    private var cache: MemoryCacheSuite!
    private var dismissRecorder: AnnouncementRecorder!
    private var entry: AnnouncementRecorder.Entry!
    private let key = AnnouncementRecord.Key.pax

    override func setUp() {
        super.setUp()
        cache = MemoryCacheSuite()
        dismissRecorder = AnnouncementRecorder(cache: cache)
        entry = dismissRecorder[key]
    }

    func testOnTimeRecordIsDismissedInCacheSuite() {
        XCTAssertTrue(entry.displayState.isShown)
        entry.markDismissed(category: .oneTime)
        XCTAssertTrue(entry.displayState.isHidden)
    }

    func testPeriodicRecordIsDismissedInCacheSuite() {
        XCTAssertTrue(entry.displayState.isShown)
        entry.markDismissed(category: .periodic)
        XCTAssertTrue(entry.displayState.isConditional)
    }
}
