//
//  Enable2FAAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Enable 2-FA announcement
final class Enable2FAAnnouncement: PeriodicAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.TwoFA.ctaButton
        )
        button.tapRelay
            .bind { [unowned self] in
                self.markDismissed()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)
        
        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-lock"),
            title: LocalizationConstants.AnnouncementCards.TwoFA.title,
            description: LocalizationConstants.AnnouncementCards.TwoFA.description,
            buttons: [button],
            dismissState: .dismissible {
                self.markDismissed()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        guard shouldEnable2FA else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.twoFA
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    let appearanceRules: PeriodicAnnouncementAppearanceRules
    
    private let shouldEnable2FA: Bool
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(shouldEnable2FA: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         reappearanceTimeInterval: TimeInterval,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldEnable2FA = shouldEnable2FA
        recorder = AnnouncementRecorder(cache: cacheSuite)
        appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.dismiss = dismiss
        self.action = action
    }
}
