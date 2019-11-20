//
//  AnnouncementError.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Possible error types during announcement flow
public enum AnnouncementError: Error {
    
    /// Wallet uninitialized
    case uninitializedWallet
}
