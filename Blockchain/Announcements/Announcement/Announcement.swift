//
//  Announcement.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Protocol for an announcement that is shown to the user. These are typically
/// used for new products and features that we launch in the wallet.
protocol Announcement {
    
    /// Indicates whether the announcement should show.
    /// Should be overridden by the inheriting concrete type.
    var shouldShow: Bool { get }
    
    /// The view model of the announcement card
    var viewModel: AnnouncementCardViewModel { get }
    
    /// The type of the announcement
    var type: AnnouncementType { get }
    
    /// The analytics recorder
    var analyticsRecorder: AnalyticsEventRecording { get }
    
    /// An analytics event for appearance
    var didAppearAnalyticsEvent: AnalyticsEvents.Announcement { get }
}

extension Announcement {
    var didAppearAnalyticsEvent: AnalyticsEvents.Announcement {
        return .init(name: .shown, type: type)
    }
}
