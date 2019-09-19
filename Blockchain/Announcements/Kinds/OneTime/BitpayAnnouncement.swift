//
//  BitpayAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// This announcement introduces Bitpay
final class BitpayAnnouncement: OneTimeAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(
                name: "card-icon-bitpay",
                size: CGSize(width: 115, height: 40)
            ),
            description: LocalizationConstants.AnnouncementCards.Bitpay.description,
            dismissState: .dismissible {
                self.markRemoved()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        return !isDismissed
    }
    
    let type = AnnouncementType.bitpay
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    // MARK: - Setup
    
    init(cacheSuite: CacheSuite = UserDefaults.standard,
         dismiss: @escaping CardAnnouncementAction) {
        self.recorder = AnnouncementRecorder(cache: cacheSuite)
        self.dismiss = dismiss
    }
}
