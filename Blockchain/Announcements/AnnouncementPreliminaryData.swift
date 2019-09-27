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
    
    /// Whether the wallet has trades or not
    let hasTrades: Bool
    
    let hasPaxTransactions: Bool
    
    let country: KYCCountry?
        
    var hasLinkedPitAccount: Bool {
        return user.hasLinkedPITAccount
    }
    
    var isKycSupported: Bool {
        return country?.isKycSupported ?? false
    }
    
    init(user: NabuUser, tiers: KYCUserTiersResponse, hasTrades: Bool, hasPaxTransactions: Bool, countries: Countries) {
        self.user = user
        self.tiers = tiers
        self.hasTrades = hasTrades
        self.hasPaxTransactions = hasPaxTransactions
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
