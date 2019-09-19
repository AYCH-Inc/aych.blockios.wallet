//
//  WalletIntroductionEvent.swift
//  Blockchain
//
//  Created by AlexM on 8/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum WalletIntroductionAnalyticsEventType: AnalyticsEvent {
    case portfolioViewed
    case sendViewed
    case requestViewed
    case swapViewed
    case buySellViewed
    
    var name: String {
        switch self {
        case .portfolioViewed:
            return "wallet_intro_portfolio_viewed"
        case .sendViewed:
            return "wallet_intro_send_viewed"
        case .requestViewed:
            return "wallet_intro_request_viewed"
        case .swapViewed:
            return "wallet_intro_swap_viewed"
        case .buySellViewed:
            return "wallet_intro_buysell_viewed"
        }
    }
    
    var params: [String : String]? {
        return nil
    }
}

// A closure executed when the user taps on a `selection` in a
// `WalletIntroductionEvent`
typealias WalletIntroductionAction = () -> Void

// Basic Introduction Event.
protocol WalletIntroductionEvent {
    
    // Action when the user selects `Next` or taps the `Pulse`
    var selection: WalletIntroductionAction { get }
    
    /// Indicates whether the event should occur
    var shouldShow: Bool { get }
    
    /// The type of WalletIntroductionEvent
    var type: WalletIntroductionEventType { get }
}

// An introduction event that can be tracked given its analytics key
protocol WalletIntroductionAnalyticsEvent {
    var eventType: WalletIntroductionAnalyticsEventType { get }
}

// An Introduction Event that needs to be flagged as completed in order for it to
// no longer be viewed
protocol CompletableWalletIntroductionEvent: WalletIntroductionEvent {
    
    /// Record that the user interacted with the Introduction Event
    var introductionRecorder: WalletIntroductionRecorder { get }
    
    /// Represents the entry in the data-set (memory/disk)
    var introductionEntry: WalletIntroductionRecorder.Entry { get }
}
