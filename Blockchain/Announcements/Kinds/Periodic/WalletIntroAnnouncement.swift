//
//  WalletIntroAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxCocoa

/// Wallet Intro announcement is a periodic announcement that can also be entirely removed
final class WalletIntroAnnouncement: PeriodicAnnouncement & RemovableAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let ctaButton = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Welcome.ctaButton
        )
        ctaButton.tapRelay
            .bind { [unowned self] in
                self.markRemoved()
                self.action()
                self.dismiss()
            } 
            .disposed(by: disposeBag)
        
        let skipButton = ButtonViewModel.secondary(
            with: LocalizationConstants.AnnouncementCards.Welcome.skipButton
        )
        skipButton.tapRelay
            .bind { [unowned self] in
                self.markDismissed()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "logo"),
            title: LocalizationConstants.AnnouncementCards.Welcome.title,
            description: LocalizationConstants.AnnouncementCards.Welcome.description,
            buttons: [ctaButton, skipButton],
            dismissState: .undismissible
        )
    }
    
    var shouldShow: Bool {
        return !isDismissed
    }
    
    let type = AnnouncementType.walletIntro
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    let action: CardAnnouncementAction
    
    let appearanceRules: PeriodicAnnouncementAppearanceRules
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(cacheSuite: CacheSuite = UserDefaults.standard,
         reappearanceTimeInterval: TimeInterval,
         action: @escaping CardAnnouncementAction,
         dismiss: @escaping CardAnnouncementAction) {
        recorder = AnnouncementRecorder(cache: cacheSuite)
        appearanceRules = PeriodicAnnouncementAppearanceRules(
            recessDurationBetweenDismissals: reappearanceTimeInterval,
            maxDismissalCount: 3
        )
        self.action = action
        self.dismiss = dismiss
    }
}
