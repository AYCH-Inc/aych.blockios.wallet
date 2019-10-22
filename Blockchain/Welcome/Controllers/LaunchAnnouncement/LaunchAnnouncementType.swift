//
//  LaunchAnnouncementType.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Welcome screen update type
enum LaunchAnnouncementType {
    
    /// Backend under maintenance
    case maintenance(WalletOptions)
    
    /// Version update
    case updateIfNeeded(WalletOptions.UpdateType)
    
    /// Warning about jailbroken phones
    case jailbrokenWarning
}
