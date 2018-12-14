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
    typealias Action = ((KYCTier) -> Void)
    
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
    let action: Action
}

extension KYCTierCellModel {
    
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
    static let demo: KYCTierCellModel = KYCTierCellModel(
    tier: .tier1, status: .inReview) { tier in
        print("")
    }
    static let demo2: KYCTierCellModel = KYCTierCellModel(
    tier: .tier2, status: .none) { tier in
        print("")
    }
}
