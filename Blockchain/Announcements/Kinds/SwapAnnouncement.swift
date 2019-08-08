//
//  SwapAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class SwapAnnouncement: DismissibleAnnouncement, CardAnnouncement {
    
    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.swapCTA(
            action: approve,
            onClose: {
                self.dismissEntry.markDismissed()
                self.dismiss()
            }
        )
        return .card(viewModel)
    }
    
    var shouldShow: Bool {
        guard isSwapEnabled else {
            return false
        }
        guard !hasTrades else {
            return false
        }
        return !dismissEntry.isDismissed
    }
    
    /// Invoked upon dismissing Swap announcement
    let dismiss: CardAnnouncementAction
    
    /// Invoked upon approving Swap announcement
    let approve: CardAnnouncementAction
    
    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.shouldHideSwapCard.rawValue]
    }
    
    private let isSwapEnabled: Bool
    private let hasTrades: Bool
    
    // MARK: - Setup
    
    init(isSwapEnabled: Bool,
         hasTrades: Bool,
         dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.isSwapEnabled = isSwapEnabled
        self.hasTrades = hasTrades
        self.dismissRecorder = dismissRecorder
        self.dismiss = dismiss
        self.approve = approve
    }
}
