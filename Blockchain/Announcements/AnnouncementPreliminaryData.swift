//
//  AnnouncementPreliminaryData.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {

    /// The nabu user
    let user: NabuUser
    
    /// User tiers information
    let tiers: KYCUserTiersResponse
    
    /// Whether the wallet has trades or not
    let hasTrades: Bool
    
    let hasPaxTransactions: Bool
    
    let country: KYCCountry?
        
    /// The variant for pit linking
    let pitLinkingCardVariant: FeatureTestingVariant
    
    /// The authentication type (2FA / standard)
    let authenticatorType: AuthenticatorType
    
    var hasLinkedPitAccount: Bool {
        return user.hasLinkedPITAccount
    }
    
    var isKycSupported: Bool {
        return country?.isKycSupported ?? false
    }
    
    var hasTwoFA: Bool {
        return authenticatorType != .standard
    }
    
    var hasReceivedBlockstackAirdrop: Bool {
        guard let campaign = airdropCampaigns.campaign(by: .blockstack) else {
            return false
        }
        return campaign.currentState == .received
    }
    
    private let airdropCampaigns: AirdropCampaigns
        
    init(user: NabuUser,
         tiers: KYCUserTiersResponse,
         airdropCampaigns: AirdropCampaigns,
         hasTrades: Bool,
         hasPaxTransactions: Bool,
         countries: Countries,
         pitLinkingCardVariant: FeatureTestingVariant,
         authenticatorType: AuthenticatorType) {
        self.pitLinkingCardVariant = pitLinkingCardVariant
        self.airdropCampaigns = airdropCampaigns
        self.user = user
        self.tiers = tiers
        self.hasTrades = hasTrades
        self.hasPaxTransactions = hasPaxTransactions
        self.authenticatorType = authenticatorType
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
