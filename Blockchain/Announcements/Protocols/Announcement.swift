//
//  Announcement.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol for an announcement shown to the user. These are typically
/// used by new products/features that we launch in the wallet.
protocol Announcement {
    
    /// Indicates whether the announcement should show
    var shouldShow: Bool { get }
    
    /// The type of the announcement
    var type: AnnouncementType { get }
}
