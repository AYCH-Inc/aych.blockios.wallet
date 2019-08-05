//
//  UploadDocumentsAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class UploadDocumentsAnnouncement: Announcement, CardAnnouncement {
    
    // MARK: - Properties
    
    var type: AnnouncementType {
        let viewModel = AnnouncementCardViewModel.resubmitDocuments(
            action: approve,
            onClose: dismiss
        )
        return .card(viewModel)
    }
    
    var shouldShow: Bool {
        return user.needsDocumentResubmission != nil
    }
    
    /// Invoked upon dismissing PAX announcement
    let dismiss: CardAnnouncementAction
    
    /// Invoked upon approving PAX announcement
    let approve: CardAnnouncementAction
    
    // MARK: - Dependencies
    
    private let user: NabuUser
    
    // MARK: - Setup
    
    init(user: NabuUser,
         dismiss: @escaping CardAnnouncementAction,
         approve: @escaping CardAnnouncementAction) {
        self.user = user
        self.dismiss = dismiss
        self.approve = approve
    }
}
