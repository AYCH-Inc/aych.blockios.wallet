//
//  CompleteProfileAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class CompleteProfileAnnouncement: DismissibleAnnouncement, CardAnnouncement {
    
    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.completeYourProfile(
            action: {
                self.dismissEntry.markDismissed()
                self.approve()
            }, onClose: {
                self.dismissEntry.markDismissed()
                self.dismiss()
        })

        return .card(viewModel)
    }
    
    var shouldShow: Bool {
        guard airdropConfig.isEnabled else {
            return false
        }
        guard !appSettings.didTapOnAirdropDeepLink else {
            return false
        }
        guard tiers.canCompleteTier2 else {
            return false
        }
        guard onboardingSettings.hasSeenGetFreeXlmModal else {
            return false
        }
        return !dismissEntry.isDismissed
    }
    
    /// Invoked upon dismissing PAX announcement
    let dismiss: CardAnnouncementAction
    
    /// Invoked upon approving PAX announcement
    let approve: CardAnnouncementAction
    
    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.hasDismissedCompleteYourProfileCard.rawValue]
    }
    
    // MARK: - Services
    
    private let onboardingSettings: BlockchainSettings.Onboarding
    private let appSettings: BlockchainSettings.App
    
    private let airdropConfig: AppFeatureConfiguration
    private let tiers: KYCUserTiersResponse
    
    // MARK: - Setup
    
    init(dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(),
         onboardingSettings: BlockchainSettings.Onboarding,
         appSettings: BlockchainSettings.App,
         airdropConfig: AppFeatureConfiguration,
         tiers: KYCUserTiersResponse,
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.dismissRecorder = dismissRecorder
        self.onboardingSettings = onboardingSettings
        self.appSettings = appSettings
        self.airdropConfig = airdropConfig
        self.tiers = tiers
        self.dismiss = dismiss
        self.approve = approve
    }
}
