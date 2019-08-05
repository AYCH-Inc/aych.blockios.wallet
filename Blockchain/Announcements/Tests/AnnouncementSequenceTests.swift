//
//  AnnouncementSequenceTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class AnnouncementSequenceTests: XCTestCase {
    
    /// Tests a scenario where there is one announcement that should show
    func testOneAnnouncementShowShow() {
        let announcements = [
            MockAnnouncement(shouldShow: false, type: .welcomeCards),
            MockAnnouncement(shouldShow: false, type: .welcomeCards),
            MockAnnouncement(shouldShow: true, type: .alert(.init(headline: "must show", body: "must show"))),
            MockAnnouncement(shouldShow: false, type: .welcomeCards)
        ]
        var sequence = AnnouncementSequence(announcements: announcements)
        guard let next = sequence.next() else {
            XCTFail("announcement is nil a valid value was expected")
            return
        }
        XCTAssertTrue(next.shouldShow)
        
        switch next.type {
        case .alert:
            XCTAssertTrue(true)
        default:
            XCTFail("expected wecomeCards announcement, got \(next.type)")
        }
        
        // Must be nil as the only truthy `shouldShow` announcement was `.alert`
        XCTAssertNil(sequence.next())
    }
    
    /// Tests a scenario where no announcements that should show
    func testNoAnnouncementShouldShow() {
        let announcements = [
            MockAnnouncement(shouldShow: false, type: .welcomeCards),
            MockAnnouncement(shouldShow: false, type: .welcomeCards)
        ]
        var sequence = AnnouncementSequence(announcements: announcements)
        XCTAssertNil(sequence.next())
    }
    
    /// Tests a scenario where multiple announcements should show
    func testMultipleAnnouncementsShouldShow() {
        
        // Each of the announcements is valid
        let announcements = [
            MockAnnouncement(shouldShow: true, type: .alert(.init(headline: "first", body: "first"))),
            MockAnnouncement(shouldShow: true, type: .alert(.init(headline: "second", body: "second"))),
            MockAnnouncement(shouldShow: true, type: .alert(.init(headline: "third", body: "third")))
        ]
        var sequence = AnnouncementSequence(announcements: announcements)
        for announcement in announcements {
            guard let next = sequence.next() else {
                XCTFail("got a nil value in next")
                return
            }
            
            // Each announcement must show
            XCTAssertTrue(next.shouldShow)
            
            // Verify respective identity of the announcement using its associated value
            switch (announcement.type, next.type) {
            case (.alert(let first), .alert(let second)) where first.headline == second.headline:
                break
            default:
                XCTFail("announcements mismatch")
            }
            
        }
        // No more valid annuoncements
        XCTAssertNil(sequence.next())
    }
}
