//
//  JoinStellarAirdropWhitelistAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class JoinStellarAirdropWhitelistAnnouncement: DismissibleAnnouncement, CardAnnouncement {
    
    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.joinAirdropWaitlist(
            action: approve,
            onClose: {
                self.dismissEntry.markDismissed()
                self.dismiss()
            }
        )
        return .card(viewModel)
    }
    
    var shouldShow: Bool {
        guard airdropConfig.isEnabled else {
            return false
        }
        guard !appSettings.didTapOnAirdropDeepLink else {
            return false
        }
        guard popupConfig.isEnabled else {
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
        return dismissRecorder[UserDefaults.Keys.hasSeenAirdropJoinWaitlistCard.rawValue]
    }
    
    // MARK: - Services
    
    private let airdropConfig: AppFeatureConfiguration
    private let popupConfig: AppFeatureConfiguration
    private let appSettings: BlockchainSettings.App
    
    // MARK: - Setup
    
    init(airdropConfig: AppFeatureConfiguration,
         popupConfig: AppFeatureConfiguration,
         appSettings: BlockchainSettings.App,
         dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.airdropConfig = airdropConfig
        self.popupConfig = popupConfig
        self.appSettings = appSettings
        self.dismissRecorder = dismissRecorder
        self.dismiss = dismiss
        self.approve = approve
    }
}

