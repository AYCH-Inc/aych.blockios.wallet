//
//  PAXAnnouncement.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Announcement that introduces PAX asset
final class PAXAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Pax.ctaButton,
            background: .paxos
        )
        button.tapRelay
            .bind { [unowned self] in
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "filled_pax_small"),
            title: LocalizationConstants.AnnouncementCards.Pax.title,
            description: LocalizationConstants.AnnouncementCards.Pax.description,
            buttons: [button],
            dismissState: .dismissible {
                self.markRemoved()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        guard !hasTransactions else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.pax

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    let action: CardAnnouncementAction
    
    private let hasTransactions: Bool
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup

    init(hasTransactions: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.hasTransactions = hasTransactions
        self.recorder = AnnouncementRecorder(cache: cacheSuite)
        self.dismiss = dismiss
        self.action = action
    }
}
