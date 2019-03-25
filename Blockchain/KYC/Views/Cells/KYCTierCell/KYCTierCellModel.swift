//
//  KYCTierCellModel.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

public struct KYCTierCellModel {
    
    // TODO: Likely to be replaced
    // Only using this to test cells
    enum ApprovalStatus {
        case none
        case infoRequired
        case inReview
        case underReview
        case approved
        case rejected
    }
    
    let tier: KYCTier
    let status: ApprovalStatus
    let limit: Decimal
    let fiatCurrencySymbol: String
}

extension KYCTierCellModel {
    
    var limitDescription: String {
        let formatter: NumberFormatter = NumberFormatter.localCurrencyFormatterWithGroupingSeparator
        return fiatCurrencySymbol + (formatter.string(from: limit as NSDecimalNumber) ?? "0.0")
    }
    
    var requirementsVisibility: Visibility {
        guard status == .none else { return .hidden }
        return .visible
    }
    
    var statusVisibility: Visibility {
        switch status {
        case .none,
             .rejected:
            return .hidden
        case .inReview,
             .infoRequired,
             .underReview,
             .approved:
            return .visible
        }
    }
    
    var headlineContainerVisibility: Visibility {
        guard tier.headline != nil else { return .hidden }
        let hide: [ApprovalStatus] = [.rejected, .approved]
        guard hide.contains(where: { $0 == self.status }) == false else { return .hidden }
        return .visible
    }
    
    var durationEstimateVisibility: Visibility {
        guard status == .none else { return .hidden }
        return .visible
    }
}

extension KYCTierCellModel.ApprovalStatus {
    var description: String? {
        switch self {
        case .none:
            return nil
        case .infoRequired:
            return LocalizationConstants.KYC.swapStatusInReviewCTA
        case .inReview:
            return LocalizationConstants.KYC.swapStatusInReview
        case .underReview:
            return LocalizationConstants.KYC.swapStatusUnderReview
        case .approved:
            return LocalizationConstants.KYC.swapStatusApproved
        case .rejected:
            return nil
        }
    }
    
    var color: UIColor? {
        switch self {
        case .none,
             .rejected:
            return #colorLiteral(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        case .infoRequired,
             .inReview:
            return #colorLiteral(red: 0.95, green: 0.55, blue: 0.19, alpha: 1)
        case .underReview:
            return #colorLiteral(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
        case .approved:
            return #colorLiteral(red: 0.21, green: 0.66, blue: 0.46, alpha: 1)
        }
    }
    
    var image: UIImage {
        switch self {
        case .none:
            return #imageLiteral(resourceName: "icon_chevron.pdf")
        case .rejected:
            return #imageLiteral(resourceName: "icon_lock.pdf")
        case .infoRequired,
             .inReview:
            return #imageLiteral(resourceName: "icon_clock.pdf")
        case .underReview:
            return #imageLiteral(resourceName: "icon_alert.pdf")
        case .approved:
            return #imageLiteral(resourceName: "icon_check.pdf")
        }
    }
}

extension KYCTierCellModel {
    
    static func model(
        from userTier: KYCUserTier,
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared
    ) -> KYCTierCellModel? {
        let value = approvalStatusFromTierState(userTier.state)
        guard let limits = userTier.limits else { return nil }
        let symbol = appSettings.fiatSymbolFromCode(currencyCode: limits.currency) ?? "$"
        let limit: Decimal = (limits.annual ?? limits.daily) ?? 0.0
        return KYCTierCellModel(tier: userTier.tier, status: value, limit: limit, fiatCurrencySymbol: symbol)
    }
    
    fileprivate static func approvalStatusFromTierState(_ tierState: KYCTierState) -> ApprovalStatus {
        switch tierState {
        case .none:
            return .none
        case .verified:
            return .approved
        case .pending:
            return .inReview
        case .rejected:
            return .rejected
        }
    }
}
