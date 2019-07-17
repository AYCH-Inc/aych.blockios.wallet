//
//  DisplayAddressStatus.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Represents the status of a displayable address
enum DisplayAddressStatus {
    
    /// Ready to fetch a new address
    case awaitingFetch
    
    /// Fetching in progress
    case fetching
    
    /// Fetch failure with associated localized reason
    case fetchFailure(localizedReason: String)
    
    /// Valid address status
    case readyForDisplay(content: WalletAddressContent)
    
    /// Returns `true` if the status is `awaitingFetch`
    var isAwaitingFetch: Bool {
        return self == .awaitingFetch
    }
    
    /// Returns `true` if the status is `readyForDisplay`
    var isReady: Bool {
        switch self {
        case .readyForDisplay:
            return true
        case .awaitingFetch, .fetching, .fetchFailure:
            return false
        }
    }
    
    /// Returns the content of the address
    var addressContent: WalletAddressContent? {
        switch self {
        case .readyForDisplay(content: let content):
            return content
        case .awaitingFetch, .fetching, .fetchFailure:
            return nil
        }
    }
}

// MARK: - Equatable

extension DisplayAddressStatus: Equatable {
    static func == (lhs: DisplayAddressStatus, rhs: DisplayAddressStatus) -> Bool {
        switch (lhs, rhs) {
        case (.awaitingFetch, .awaitingFetch),
             (.fetching, .fetching),
             (.fetchFailure, .fetchFailure),
             (.readyForDisplay, .readyForDisplay):
            return true
        default:
            return false
        }
    }
}

