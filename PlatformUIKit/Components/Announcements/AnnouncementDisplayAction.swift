//
//  AnnouncementDisplayAction.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A action that needs to be taken to display an announcement to the user
public enum AnnouncementDisplayAction: Equatable {
    
    /// Show an announcement
    case show(AnnouncementCardViewModel)
    
    /// Agnostically hide whatever announcement that is currently displayed
    case hide
    
    /// No announcement
    case none
    
    public static func == (lhs: AnnouncementDisplayAction, rhs: AnnouncementDisplayAction) -> Bool {
        switch (lhs, rhs) {
        case (.show(let first), .show(let second)):
            return first == second
        case (.hide, .hide), (.none, .none):
            return true
        default:
            return false
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension AnnouncementDisplayAction: CustomDebugStringConvertible {
    public var debugDescription: String {
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
