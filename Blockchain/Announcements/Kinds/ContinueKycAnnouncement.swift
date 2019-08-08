//
//  ContinueKycAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class ContinueKycAnnouncement: Announcement, CardAnnouncement {
    
    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.continueWithKYC(
            isAirdropUser: user.isSunriverAirdropRegistered,
            action: approve,
            onClose: dismiss
        )
        return .card(viewModel)
    }
    
    var shouldShow: Bool {
        return isCompletingKyc
    }
    
    /// Invoked upon dismissing announcement
    let dismiss: CardAnnouncementAction
    
    /// Invoked upon approving announcement
    let approve: CardAnnouncementAction
    
    // MARK: - Dependencies
    
    private let user: NabuUserSunriverAirdropRegistering
    private let isCompletingKyc: Bool
    
    // MARK: - Setup
    
    init(user: NabuUserSunriverAirdropRegistering,
         isCompletingKyc: Bool,
         dismissRecorder: AnnouncementDismissRecorder = AnnouncementDismissRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.user = user
        self.isCompletingKyc = isCompletingKyc
        self.dismiss = dismiss
        self.approve = approve
    }
}
