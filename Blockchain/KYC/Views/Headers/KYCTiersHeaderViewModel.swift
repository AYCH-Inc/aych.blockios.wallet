//
//  KYCTiersHeaderViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// This view model is used in `KYCTiersPageModel`. It dictates what
/// type of header this screen has and what information should be displayed
/// in said header.
enum KYCTiersHeaderViewModel {
    enum Action {
        case learnMore
        case contactSupport
        case swapNow
    }
    typealias Amount = String
    
    /// `AmountDescription` is either a value that describes what `Swap` is
    /// or it can be informing the user that their currently being reviewed for
    /// `Tier Two`. These are the two states outlined in the comps. 
    typealias AmountDescription = String
    
    case available(Amount, AmountDescription, suppressDismissCTA: Bool)
    case availableToday(Amount, AmountDescription, suppressDismissCTA: Bool)
    case unavailable(actions: [Action]?, suppressDismissCTA: Bool)
    case empty(suppressDismissCTA: Bool)
}

extension KYCTiersHeaderViewModel {
    /// This is a convenience function for showing the `unavailable` header state
    /// without any CTAs.
    fileprivate static func unavailable(suppressDismissCTA: Bool) -> KYCTiersHeaderViewModel {
        return .unavailable(
            actions: nil,
            suppressDismissCTA: suppressDismissCTA
        )
    }
    
    var suppressDismissCTA: Bool {
        switch self {
        case .available(_, _, let value):
            return value
        case .availableToday(_, _, let value):
            return value
        case .unavailable(_, let value):
            return value
        case .empty(let value):
            return value
        }
    }
    
    var identifier: String {
        switch self {
        case .unavailable,
             .empty:
            return KYCCTAHeaderView.identifier
        case .available,
             .availableToday:
            return KYCAvailableFundsHeaderView.identifier
        }
    }
    
    var headerType: KYCTiersHeaderView.Type {
        switch self {
        case .unavailable,
            .empty:
            return KYCCTAHeaderView.self
        case .available,
             .availableToday:
            return KYCAvailableFundsHeaderView.self
        }
    }
    
    func estimatedHeight(for width: CGFloat, model: KYCTiersHeaderViewModel) -> CGFloat {
        return headerType.estimatedHeight(
            for: width,
            model: self
        )
    }
}

extension KYCTiersHeaderViewModel: Equatable {
    static func == (lhs: KYCTiersHeaderViewModel, rhs: KYCTiersHeaderViewModel) -> Bool {
        switch (lhs, rhs) {
        case (.available(let lhsAmount, let lhsDescription, _), .available(let rhsAmount, let rhsDescription, _)):
            return lhsAmount == rhsAmount &&
            lhsDescription == rhsDescription
        case (.availableToday(let lhsAmount, let lhsDescription, _), .availableToday(let rhsAmount, let rhsDescription, _)):
            return lhsAmount == rhsAmount &&
                lhsDescription == rhsDescription
        case (.unavailable, .unavailable):
            return true
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension KYCTiersHeaderViewModel {
    
    var amountVisibility: Visibility {
        switch self {
        case .available,
             .availableToday:
            return .visible
        case .unavailable,
             .empty:
            return .hidden
        }
    }
    
    var amount: String? {
        switch self {
        case .available(let value, _, _):
            return value
        case .availableToday(let value, _, _):
            return value
        case .unavailable,
             .empty:
            return nil
        }
    }
    
    var actions: [Action]? {
        switch self {
        case .available,
             .availableToday,
             .empty:
            return nil
        case .unavailable(let value, _):
            return value
        }
    }
    
    var availabilityTitle: String? {
        switch self {
        case .available:
            return LocalizationConstants.KYC.available
        case .availableToday:
            return LocalizationConstants.KYC.availableToday
        case .unavailable,
             .empty:
            return nil
        }
    }
    
    var availabilityDescription: String? {
        switch self {
        case .available(_, let description, _):
            return description
        case .availableToday(_, let description, _):
            return description
        case .unavailable,
             .empty:
            return nil
        }
    }
    
    var subtitle: String? {
        switch self {
        case .available,
             .availableToday:
            return nil
        case .unavailable:
            return LocalizationConstants.KYC.swapUnavailableDescription
        case .empty:
            return LocalizationConstants.KYC.swapAnnouncement
        }
    }
    
    var title: String? {
        switch self {
        case .available,
             .availableToday:
            return nil
        case .unavailable:
            return LocalizationConstants.KYC.swapUnavailable
        case .empty:
            return LocalizationConstants.KYC.swapTagline
        }
    }
    
}

extension KYCTiersHeaderViewModel {
    
    static func make(
        with tierResponse: KYCUserTiersResponse,
        availableFunds: String? = nil,
        suppressDismissCTA: Bool = false
    ) -> KYCTiersHeaderViewModel {
        let tiers = tierResponse.userTiers.filter({ $0.tier != .tier0 })
        
        guard let tier1 = tiers.filter({ $0.tier == .tier1 }).first else {
            /// This should never occur
            return unavailable(suppressDismissCTA: suppressDismissCTA)
        }
        guard let tier2 = tiers.filter({ $0.tier == .tier2 }).first else {
            /// This should never occur
            return unavailable(suppressDismissCTA: suppressDismissCTA)
        }
        
        switch (tier1.state, tier2.state) {
        case (.none, _),
             (.pending, .none):
            /// Showing any available amount here wouldn't be useful since
            /// `.pending` for Tier 1 means they can't actually make any trades.
            return .empty(suppressDismissCTA: suppressDismissCTA)
        case (.rejected, .none),
             (.rejected, .pending):
            return .unavailable(suppressDismissCTA: suppressDismissCTA)
            /// In the case that `Tier1` and `Tier2` is rejected
            /// or if `Tier2` is rejected, we want to show the CTAs
            /// that prompt the user to contact support.
        case (.rejected, .rejected),
             (_, .rejected):
            return .unavailable(
                actions: [.learnMore, .contactSupport],
                suppressDismissCTA: suppressDismissCTA
            )
        case (.pending, .pending),
             (.verified, .pending):
            guard let amount = availableFunds else { return unavailable(suppressDismissCTA: suppressDismissCTA) }
            let formatted = "$" + amount
            return .available(
                formatted, LocalizationConstants.KYC.tierTwoVerificationIsBeingReviewed,
                suppressDismissCTA: suppressDismissCTA
            )
        case (_, .verified):
            guard let amount = availableFunds else { return unavailable(suppressDismissCTA: suppressDismissCTA) }
            let formatted = "$" + amount
            return .availableToday(
                formatted,
                LocalizationConstants.KYC.swapLimitDescription,
                suppressDismissCTA: suppressDismissCTA
            )
        case (.verified, .none):
            guard let amount = availableFunds else { return unavailable(suppressDismissCTA: suppressDismissCTA) }
            let formatted = "$" + amount
            return .available(
                formatted,
                LocalizationConstants.KYC.swapLimitDescription,
                suppressDismissCTA: suppressDismissCTA
            )
        }
    }
}

extension KYCTiersHeaderViewModel {
    /// NOTE: This is for demo'ing and debugging the tiers header view
    /// As there are a few different permutations, please leave this here for now.
    static let availableToday: KYCTiersHeaderViewModel = .availableToday(
        "$25,000",
        LocalizationConstants.KYC.swapLimitDescription,
        suppressDismissCTA: true
    )
    
    static let empty: KYCTiersHeaderViewModel = unavailable(
        suppressDismissCTA: false
    )
}
