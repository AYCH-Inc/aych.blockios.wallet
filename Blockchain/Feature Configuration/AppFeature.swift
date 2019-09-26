//
//  AppFeature.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc enum AppFeature: Int, CaseIterable {
    case biometry
    case swipeToReceive
    case transferFundsFromImportedAddress

    /// Sunriver
    case stellar
    case stellarAirdrop
    case stellarAirdropPopup
    case stellarLargeBacklog

    /// Coinify
    case notifyCoinifyUserToKyc
    
    /// Pit linking enabled
    case pitLinking
    
    /// Pit announcement visibility
    case pitAnnouncement
    
    /// The announcments
    case announcements
    
    /// Title for the PIT side menu
    case pitSideNavigationVariant
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    var remoteEnabledKey: String? {
        switch self {
        case .stellarAirdrop:
            return "ios_sunriver_airdrop_enabled"
        case .notifyCoinifyUserToKyc:
            return "ios_notify_coinify_users_to_kyc"
        case .stellarAirdropPopup:
            return "get_free_xlm_popup"
        case .stellarLargeBacklog:
            return "sunriver_has_large_backlog"
        case .pitLinking:
            return "pit_linking_enabled"
        case .pitAnnouncement:
            return "pit_show_announcement"
        case .announcements:
            return "announcements"
        case .pitSideNavigationVariant:
            return "ab_the_pit_side_nav_variant"
        default:
            return nil
        }
    }
}
