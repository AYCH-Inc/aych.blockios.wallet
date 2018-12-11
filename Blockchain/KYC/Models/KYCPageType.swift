//
//  KYCPage.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCPageType {
    case enterEmail
    case confirmEmail
    case welcome
    case country
    case states
    case profile
    case address
    case enterPhone
    case confirmPhone
    case verifyIdentity
    case accountStatus
    case applicationComplete
}

extension KYCPageType {

    static func startingPage(forUser user: NabuUser, tier: KYCTier) -> KYCPageType {
        switch tier {
        case .tier1:
            // TODO: check if email is already verified
            return .enterEmail
        case .tier2:
            // TODO: check if user is already tier1 verified, if not, start from tier1 starting page
            if let mobile = user.mobile, mobile.verified {
                return .verifyIdentity
            }
            return .enterPhone
        }
    }

    func nextPage(forTier tier: KYCTier, user: NabuUser?, country: KYCCountry?) -> KYCPageType? {
        switch tier {
        case .tier1:
            return nextPageTier1(user: user, country: country)
        case .tier2:
            return nextPageTier2(user: user, country: country)
        }
    }

    private func nextPageTier1(user: NabuUser?, country: KYCCountry?) -> KYCPageType? {
        switch self {
        case .enterEmail:
            return .confirmEmail
        case .confirmEmail:
            return .country
        case .country:
            if let country = country, country.states.count != 0 {
                return .states
            }
            return .profile
        case .states:
            return .profile
        case .profile:
            return .address
        case .address:
            // END
            return nil
        case .welcome,
             .enterPhone,
             .confirmPhone,
             .verifyIdentity,
             .applicationComplete,
             .accountStatus:
            // All other pages don't have a next page for tier 1
            return nil
        }
    }

    private func nextPageTier2(user: NabuUser?, country: KYCCountry?) -> KYCPageType? {
        switch self {
        case .address:
            // Skip the enter phone step if the user already has verified their phone number
            if let user = user, let mobile = user.mobile, mobile.verified {
                return .verifyIdentity
            }
            return .enterPhone
        case .enterPhone:
            return .confirmPhone
        case .confirmPhone:
            return .verifyIdentity
        case .verifyIdentity:
            return .applicationComplete
        case .applicationComplete:
            // End
            return nil
        case .welcome,
             .enterEmail,
             .confirmEmail,
             .country,
             .states,
             .profile,
             .accountStatus:
            return nextPageTier1(user: user, country: country)
        }
    }
}
