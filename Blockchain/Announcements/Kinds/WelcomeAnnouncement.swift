//
//  WelcomeAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 TODO: Move presentation logic from `CardsViewController.m` into here
 TODO: Consider creating a protocol on top of `DismissibleAnnouncement` to display multiple horizontally scrollable cards
 */

final class WelcomeAnnouncement: DismissibleAnnouncement {
    
    var type: AnnouncementType {
        return .welcomeCards
    }
    
    var shouldShow: Bool {
        return true
    }
    
    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.hasSeenAllCards.rawValue]
    }
    
    // MARK: - Setup
    
    init(dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder()) {
        self.dismissRecorder = dismissRecorder
    }
}
