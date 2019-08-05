//
//  DismissibleAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 20/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Announcement that can be dismissed
protocol DismissibleAnnouncement: Announcement {
    
    /// Makes sure the announcement will not show again in a timespan
    var dismissRecorder: AnnouncementDismissRecorder { get }
    
    /// Represents the entry in the data-set (memory/disk)
    var dismissEntry: AnnouncementDismissRecorder.Entry { get }
}
