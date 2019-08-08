//
//  AirdropRegistrationAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

final class AirdropRegistrationAnnouncement: Announcement {
    
    // MARK: - Properties
    
    /// Returns the action that should be taken to show the announcement
    var type: AnnouncementType {
        dismissEntry.markDismissed()
        let getFreeXlm = AlertAction(
            style: .confirm(LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationAction),
            metadata: .block(approve)
        )
        let dismiss = AlertAction(
            style: .default(LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationCancel)
        )
        let alertModel = AlertModel(
            headline: LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationTitle,
            body: LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationDescription,
            actions: [getFreeXlm, dismiss],
            image: UIImage(named: "Icon-Verified"),
            dismissable: true,
            style: .sheet
        )
        return .alert(alertModel)
    }
    
    var shouldShow: Bool {
        guard !user.isSunriverAirdropRegistered else {
            return false
        }
        guard tiers.isTier2Pending || tiers.isTier2Verified else {
            return false
        }
        return !dismissEntry.isDismissed
    }
    
    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.hasSeenStellarAirdropRegistrationAlert.rawValue]
    }
    
    private let approve: () -> Void
    
    private let user: NabuUser
    private let tiers: KYCUserTiersResponse

    // MARK: - Setup
    
    init(user: NabuUser,
         tiers: KYCUserTiersResponse,
         dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(cache: UserDefaults.standard),
         approve: @escaping () -> Void) {
        self.user = user
        self.tiers = tiers
        self.dismissRecorder = dismissRecorder
        self.approve = approve
    }
}
