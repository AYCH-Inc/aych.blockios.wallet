//
//  CoinifyKycAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

final class CoinifyKycAnnouncement: Announcement {

    // MARK: - Types
    
    private struct Key {
        static let shouldShowCoinifyKycModal = "shouldShowCoinifyKycModal"
    }
    
    // MARK: - Properties

    /// Returns the action that should be taken to show the announcement
    var type: AnnouncementType {
        self.dismissEntry.markDismissed()
        let updateNowAction = AlertAction(
            style: .confirm(LocalizationConstants.beginNow),
            metadata: .block(confirm)
        )
        let learnMoreAction = AlertAction(
            style: .default(LocalizationConstants.AnnouncementCards.learnMore),
            metadata: .block(learnMore)
        )
        let alertModel = AlertModel(
            headline: LocalizationConstants.AnnouncementCards.bottomSheetCoinifyInfoTitle,
            body: LocalizationConstants.AnnouncementCards.bottomSheetCoinifyInfoDescription,
            actions: [updateNowAction, learnMoreAction],
            image: UIImage(named: "Icon-Information"),
            dismissable: true,
            style: .sheet
        )
        return .alert(alertModel)
    }

    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[Key.shouldShowCoinifyKycModal]
    }
    
    var shouldShow: Bool {
        guard configuration.isEnabled else {
            return false
        }
        guard tiers.canCompleteTier2 else {
            return false
        }
        // TODO: This calls JS. convert to native
        guard wallet.isCoinifyTrader() else {
            return false
        }
        return !dismissEntry.isDismissed
    }
    
    private let confirm: () -> Void
    private let learnMore: () -> Void
    
    private let configuration: AppFeatureConfiguration
    private let tiers: KYCUserTiersResponse
    private let wallet: Wallet
    
    // MARK: - Setup
    
    init(configuration: AppFeatureConfiguration,
         tiers: KYCUserTiersResponse,
         wallet: Wallet,
         dismissRecorder: AnnouncementDismissRecorder,
         confirm: @escaping () -> Void,
         learnMore: @escaping () -> Void) {
        self.configuration = configuration
        self.tiers = tiers
        self.wallet = wallet
        self.dismissRecorder = dismissRecorder
        self.confirm = confirm
        self.learnMore = learnMore
    }
}
