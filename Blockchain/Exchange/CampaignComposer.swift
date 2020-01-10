//
//  CampaignComposer.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol Campaign {
    var rawValue: String { get }
}

/// This object composes campaign parameters and provides a clear API for each supported campaign.
final class CampaignComposer {
        
    // MARK: - Types
    
    /// Query key types
    enum Key: String {
        case source = "utm_source"
        case medium = "utm_medium"
    }
    
    /// Lists the current tracked campaigns
    struct CampaignValue {
        /// Default query value types. any constant value that should be reported
        /// for any campaign
        enum General: String, Campaign {
            case source = "ios_wallet"
        }
        
        /// Exchange campaign
        enum Exchange: String, Campaign {
            case medium = "wallet_linking"
        }
    }
    
    // MARK: - Properties
    
    /// General query-value pairs that should be tracked for any campaign
    var generalQueryValuePairs: [Key: Campaign] {
        return [.source: CampaignValue.General.source,
                .medium: CampaignValue.Exchange.medium]
    }
}
