//
//  ActionableAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//


/// Action that takes place when tapping CTA / dismiss button in card announcement
typealias CardAnnouncementAction = () -> Void

/// An announcement that requires the user to take a certain action.
/// Such announcements typically contain a CTA button.
protocol ActionableAnnouncement: Announcement {
    
    /// An action for announcement (driven by CTA button)
    var action: CardAnnouncementAction { get }
    
    /// An analytics event for action
    var actionAnalyticsEvent: AnalyticsEvents.Announcement { get }
}

extension ActionableAnnouncement {
    var actionAnalyticsEvent: AnalyticsEvents.Announcement {
        return .init(name: .actioned, type: type)
    }
}
