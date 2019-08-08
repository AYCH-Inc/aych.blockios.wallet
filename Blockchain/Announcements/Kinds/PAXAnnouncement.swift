//
//  PAXAnnouncement.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class PAXAnnouncement: DismissibleAnnouncement, CardAnnouncement {

    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.paxIntro(
            action: {
                self.dismissEntry.markDismissed()
                self.approve()
            },
            onClose: {
                self.dismissEntry.markDismissed()
                self.dismiss()
            }
        )
        return .card(viewModel)
    }
    
    /// Invoked upon dismissing PAX announcement
    let dismiss: CardAnnouncementAction
    
    /// Invoked upon approving PAX announcement
    let approve: CardAnnouncementAction
    
    let dismissRecorder: AnnouncementDismissRecorder
    var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.hasSeenPAXCard.rawValue]
    }

    var shouldShow: Bool {
        return !dismissEntry.isDismissed
    }
    
    // MARK: - Setup

    init(dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.dismiss = dismiss
        self.approve = approve
        self.dismissRecorder = dismissRecorder
    }
}
