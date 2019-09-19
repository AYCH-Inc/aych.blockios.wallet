//
//  AnnouncementDisplayAction.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// A action that needs to be taken to display an announcement to the user
enum AnnouncementDisplayAction {
    
    /// Show an announcement
    case show(AnnouncementCardViewModel)
    
    /// Agnostically hide whatever announcement that is currently displayed
    case hide
    
    /// No announcement
    case none
}

// MARK: - CustomDebugStringConvertible

extension AnnouncementDisplayAction: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .show:
            return "shows card announcement"
        case .hide:
            return "hides announcement"
        case .none:
            return "doesn't show announcement"
        }
    }
}
