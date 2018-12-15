//
//  KYCPager.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class KYCPager: KYCPagerAPI {

    private let dataRepository: BlockchainDataRepository
    private(set) var tier: KYCTier

    init(
        dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
        tier: KYCTier
    ) {
        self.dataRepository = dataRepository
        self.tier = tier
    }

    func nextPage(from page: KYCPageType, payload: KYCPagePayload?) -> Maybe<KYCPageType> {

        // Get country from payload if present
        var kycCountry: KYCCountry?
        if let payload = payload {
            switch payload {
            case .countrySelected(let country):
                kycCountry = country
            case .phoneNumberUpdated,
                 .emailPendingVerification:
                // Not handled here
                break
            }
        }

        return dataRepository.nabuUser.take(1).asSingle().flatMapMaybe { [weak self] user -> Maybe<KYCPageType> in
            guard let strongSelf = self else {
                return Maybe.empty()
            }
            guard let nextPage = page.nextPage(forTier: strongSelf.tier, user: user, country: kycCountry) else {
                return strongSelf.nextPageFromNextTierMaybe()
            }
            return Maybe.just(nextPage)
        }
    }

    private func nextPageFromNextTierMaybe() -> Maybe<KYCPageType> {
        return dataRepository.fetchNabuUser().flatMapMaybe { [weak self] user -> Maybe<KYCPageType> in
            guard let strongSelf = self else {
                return Maybe.empty()
            }
            guard let tiers = user.tiers else {
                return Maybe.empty()
            }
            guard tiers.next.rawValue > tiers.selected.rawValue else {
                return Maybe.empty()
            }

            let nextTier = tiers.next
            
            guard let moreInfoPage = KYCPageType.moreInfoPage(forTier: nextTier) else {
                return Maybe.empty()
            }

            // If all guard checks pass, this means that we have determined that the user should be
            // forced to KYC on the next tier
            strongSelf.tier = nextTier

            return Maybe.just(moreInfoPage)
        }
    }
}

// MARK: KYCPageType Extensions

extension KYCPageType {

    static func startingPage(forUser user: NabuUser, tier: KYCTier) -> KYCPageType {
        switch tier {
        case .tier0,
             .tier1:
            if user.email.verified {
                return .country
            }
            return .enterEmail
        case .tier2:
            if let tiers = user.tiers, tiers.current == .tier0 {
                return startingPage(forUser: user, tier: .tier1)
            }
            if let mobile = user.mobile, mobile.verified {
                return .verifyIdentity
            }
            return .enterPhone
        }
    }

    static func lastPage(forTier tier: KYCTier) -> KYCPageType {
        switch tier {
        case .tier0,
             .tier1:
            return .address
        case .tier2:
            return .verifyIdentity
        }
    }

    static func moreInfoPage(forTier tier: KYCTier) -> KYCPageType? {
        switch tier {
        case .tier2:
            return .tier1ForcedTier2
        case .tier0,
             .tier1:
            return nil
        }
    }

    func nextPage(forTier tier: KYCTier, user: NabuUser?, country: KYCCountry?) -> KYCPageType? {
        switch tier {
        case .tier0,
             .tier1:
            return nextPageTier1(user: user, country: country)
        case .tier2:
            return nextPageTier2(user: user, country: country)
        }
    }

    private func nextPageTier1(user: NabuUser?, country: KYCCountry?) -> KYCPageType? {
        switch self {
        case .welcome:
            if let user = user {
                return KYCPageType.startingPage(forUser: user, tier: .tier1)
            }
            return .enterEmail
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
        case .tier1ForcedTier2,
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
        case .address,
             .tier1ForcedTier2:
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
            // End
            return nil
        case .applicationComplete:
            // Not used
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

