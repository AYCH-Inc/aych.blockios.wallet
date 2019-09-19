//
//  RemovableAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// Announcement that can be totally removed. Typically used for one-time announcements.
protocol RemovableAnnouncement: DismissibleAnnouncement {
    func markRemoved()
}

extension RemovableAnnouncement {
    
    /// Marks the announcement as removed, so that it will never appear again.
    func markRemoved() {
        recorder[key].markRemoved(category: category)
    }
}
