//
//  CardAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Action that takes place when displaying a card announcement
typealias CardAnnouncementAction = () -> Void

/// Announcement that is shown in card form
protocol CardAnnouncement {
    
    /// Approve action for announcement
    var approve: CardAnnouncementAction { get }
    
    /// Dismiss action for announcement
    var dismiss: CardAnnouncementAction { get }
}
