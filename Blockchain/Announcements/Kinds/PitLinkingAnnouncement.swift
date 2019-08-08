//
//  PitLinkingAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Card announcement for Wallet-PIT linking
final class PitLinkingAnnouncement: DismissibleAnnouncement, CardAnnouncement {
    
    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.walletPitLinking(
            action: approve,
            onClose: {
                self.dismissEntry.markDismissed()
                self.dismiss()
            }
        )
        return .card(viewModel)
    }
    
    var shouldShow: Bool {
        // PIT linking must be enabled in config
        guard config.isEnabled else {
            return false
        }
        return !dismissEntry.isDismissed
    }
    
    /// Invoked upon dismissing pit-linking announcement
    let dismiss: CardAnnouncementAction
    
    /// Invoked upon CTAing pit-linking announcement
    let approve: CardAnnouncementAction
    
    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.shouldHidePITLinkingCard.rawValue]
    }
    
    // MARK: - Dependencies
    
    private let config: AppFeatureConfiguration
    
    // MARK: - Setup
    
    init(config: AppFeatureConfiguration,
         dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.config = config
        self.dismissRecorder = dismissRecorder
        self.dismiss = dismiss
        self.approve = approve
    }
}
