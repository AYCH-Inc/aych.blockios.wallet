//
//  OneTimeAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A one-time announcement is a removable announcement
/// that displays only one time (up to first dismissal).
/// Once the announcement is dismissed by the user, it is
/// no longer valid and will not be displayed anymore.
public protocol OneTimeAnnouncement: RemovableAnnouncement {}
extension OneTimeAnnouncement {
    
    /// Returns the category for the announcement
    public var category: AnnouncementRecord.Category { return .oneTime }
    
    /// Resolves the category and the state into a simple boolean that
    /// Says whether the announcement is dismissed or not
    public var isDismissed: Bool {
        switch recorder[key].displayState {
        case .hide:
            return true
        case .show:
            return false
        case .conditional: // This is not implemented in one-time announcements
            return true
        }
    }
}
