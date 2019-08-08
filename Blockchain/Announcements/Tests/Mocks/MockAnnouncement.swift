//
//  MockAnnouncement.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 29/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

struct MockAnnouncement: Announcement {

    let shouldShow: Bool
    let type: AnnouncementType
    
    init(shouldShow: Bool, type: AnnouncementType) {
        self.shouldShow = shouldShow
        self.type = type
    }
}
