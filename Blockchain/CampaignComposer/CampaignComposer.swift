//
//  CampaignComposer.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
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
        case campaign1 = "utm_campaign"
        case campaign2 = "utm_campaign2"
    }
    
    /// Lists the current tracked campaigns
    struct CampaignValue {
        /// Default query value types. any constant value that should be reported
        /// for any campaign
        enum General: String, Campaign {
            case source = "ios_wallet"
        }
        
        /// Pit campaign
        enum Pit: String, Campaign {
            enum SideMenu: String, Campaign {
                case pit = "side_nav_pit"
                case trading = "side_nav_trading"
                case exchange = "side_nav_pit_exchange"
            }
            enum Announcement: String, Campaign {
                case variantA = "variant_a"
                case variantB = "variant_b"
            }
            
            case medium = "wallet_linking"
        }
    }
    
    // MARK: - Properties
    
    /// Streams the PIT campaign parameters
    var pitCampaign: Single<[Key: Campaign]> {
        return Single
            .zip(variantFetcher.fetchTestingVariant(for: .pitSideNavigationVariant, onErrorReturn: .variantA),
                 variantFetcher.fetchTestingVariant(for: .pitAnnouncementVariant, onErrorReturn: .variantA))
            .map(weak: self) { (self, variants) -> [Key: Campaign] in
                return self.pitCampaign(from: variants.0, and: variants.1)
            }
    }
    
    /// General query-value pairs that should be tracked for any campaign
    private var generalQueryValuePairs: [Key: Campaign] {
        return [.source: CampaignValue.General.source,
                .medium: CampaignValue.Pit.medium]
    }
    
    private let variantFetcher: FeatureVariantFetching
    
    // MARK: - Setup
    
    init(variantFetcher: FeatureVariantFetching = AppFeatureConfigurator.shared) {
        self.variantFetcher = variantFetcher
    }
    
    // MARK: - Private methods
    
    private func pitCampaign(from sideMenuVariant: FeatureTestingVariant,
                             and announcementVariant: FeatureTestingVariant) -> [Key: Campaign] {
        let sideMenu: [Key: Campaign] = campaignKeyValuePair(fromSideMenuVariant: sideMenuVariant)
        let announcement: [Key: Campaign] = campaignKeyValuePair(fromPitCardVariant: announcementVariant)
        return generalQueryValuePairs + announcement + sideMenu
    }
    
    private func campaignKeyValuePair(fromSideMenuVariant variant: FeatureTestingVariant) -> [Key: Campaign] {
        let value: CampaignValue.Pit.SideMenu
        switch variant {
        case .variantA:
            value = .pit
        case .variantB:
            value = .trading
        case .variantC:
            value = .exchange
        }
        return [.campaign1: value]
    }
    
    private func campaignKeyValuePair(fromPitCardVariant variant: FeatureTestingVariant) -> [Key: Campaign] {
        let value: CampaignValue.Pit.Announcement
        switch variant {
        case .variantA:
            value = .variantA
        case .variantB:
            value = .variantB
        default: // Should not arrive here
            value = .variantA
        }
        return [.campaign2: value]
    }
}
