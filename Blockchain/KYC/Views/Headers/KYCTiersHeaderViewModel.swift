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
    }
    typealias Amount = String
    
    /// `AmountDescription` is either a value that describes what `Swap` is
    /// or it can be informing the user that their currently being reviewed for
    /// `Tier Two`. These are the two states outlined in the comps. 
    typealias AmountDescription = String
    
    case available(Amount, AmountDescription)
    case availableToday(Amount, AmountDescription)
    case unavailable
    case empty
}

extension KYCTiersHeaderViewModel {
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
        case (.available(let lhsAmount, let lhsDescription), .available(let rhsAmount, let rhsDescription)):
            return lhsAmount == rhsAmount &&
            lhsDescription == rhsDescription
        case (.availableToday(let lhsAmount, let lhsDescription), .availableToday(let rhsAmount, let rhsDescription)):
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
        case .available(let value, _):
            return value
        case .availableToday(let value, _):
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
        case .unavailable:
            return [.contactSupport, .learnMore]
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
        case .available(_, let description):
            return description
        case .availableToday(_, let description):
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
        status: KYCAccountStatus,
        currencySymbol: String,
        availableFunds: String?
        ) -> KYCTiersHeaderViewModel {
        let tiers = tierResponse.userTiers.filter({ $0.tier != .tier0 })
        guard let tier2 = tiers.filter({ $0.tier == .tier2 }).first else { return .unavailable }
        
        switch status {
        case .none:
            return .empty
        case .failed,
             .expired:
            return .unavailable
        case .pending,
             .underReview:
            guard let amount = availableFunds else { return .unavailable }
            let formatted = currencySymbol + amount
            if tier2.state == .pending || tier2.state == .rejected {
                return .available(formatted, LocalizationConstants.KYC.tierTwoVerificationIsBeingReviewed)
            }
            
            return .available(formatted, LocalizationConstants.KYC.swapLimitDescription)
        case .approved:
            guard let amount = availableFunds else { return .unavailable }
            let formatted = currencySymbol + amount
            if tier2.state == .verified {
                return .availableToday(formatted, LocalizationConstants.KYC.swapLimitDescription)
            }
            
            if tier2.state == .pending || tier2.state == .rejected {
                return .available(formatted, LocalizationConstants.KYC.tierTwoVerificationIsBeingReviewed)
            }
            return .available(formatted, LocalizationConstants.KYC.swapLimitDescription)
        }
    }
}

extension KYCTiersHeaderViewModel {
    static let welcome: KYCTiersHeaderViewModel = .empty
    static let demo: KYCTiersHeaderViewModel = .unavailable
}
