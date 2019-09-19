//
//  SwapAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Swap announcement is a periodic announcement that introduces the user to in-wallet asset trading
final class SwapAnnouncement: PeriodicAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Swap.ctaButton
        )
        button.tapRelay
            .bind { [unowned self] in
                self.markDismissed()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-swap"),
            title: LocalizationConstants.AnnouncementCards.Swap.title,
            description: LocalizationConstants.AnnouncementCards.Swap.description,
            buttons: [button],
            dismissState: .dismissible {
                self.markDismissed()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        guard isSwapEnabled else {
            return false
        }
        guard !hasTrades else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.swap
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    let appearanceRules: PeriodicAnnouncementAppearanceRules
    
    private let isSwapEnabled: Bool
    private let hasTrades: Bool
    
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(isSwapEnabled: Bool,
         hasTrades: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         reappearanceTimeInterval: TimeInterval,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.isSwapEnabled = isSwapEnabled
        self.hasTrades = hasTrades
        recorder = AnnouncementRecorder(cache: cacheSuite)
        appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.dismiss = dismiss
        self.action = action
    }
}
