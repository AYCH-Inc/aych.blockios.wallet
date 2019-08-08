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
    case show(AnnouncementType)
    
    /// Agnostically hide whatever announcement that is currently displayed
    case hide
    
    /// No announcement
    case none
}

/// The type of the announcement associated with the presentation
enum AnnouncementType {
    
    /// A card announcement
    case card(AnnouncementCardViewModel)
    
    /// An alert announcement
    case alert(AlertModel)
    
    // TODO: Delete this as welcome cards logic is moved from `CardsViewController.m` into `WelcomeAnnouncement`
    /// Special temporary card for welcome cards.
    case welcomeCards
}

// MARK: - CustomDebugStringConvertible

extension AnnouncementDisplayAction: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .show(let type):
            switch type {
            case .card:
                return "shows card announcement"
            case .alert:
                return "shows alert announcement"
            case .welcomeCards:
                return "shows multiple cards announcement"
            }
        case .hide:
            return "hides announcement"
        case .none:
            return "doesn't show announcement"
        }
    }
}
