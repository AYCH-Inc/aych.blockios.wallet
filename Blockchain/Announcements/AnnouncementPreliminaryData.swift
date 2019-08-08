//
//  AnnouncementPreliminaryData.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {
    
    /// The nabu user
    let user: NabuUser
    
    /// User tiers information
    let tiers: KYCUserTiersResponse
    
    /// Whether the user has trades or not
    let hasTrades: Bool
    
    /// `true` if swap is enabled for the user
    var isSwapEnabled: Bool {
        return user.swapApproved()
    }
}
