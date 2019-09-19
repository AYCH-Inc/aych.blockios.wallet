//
//  BackupFundsAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Announcement for funds backup
final class BackupFundsAnnouncement: PeriodicAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.BackupFunds.ctaButton
        )
        button.tapRelay
            .bind { [unowned self] in
                self.markDismissed()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)
        
        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-shield"),
            title: LocalizationConstants.AnnouncementCards.BackupFunds.title,
            description: LocalizationConstants.AnnouncementCards.BackupFunds.description,
            buttons: [button],
            dismissState: .dismissible {
                self.markDismissed()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        guard shouldBackupFunds else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.backupFunds
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    let action: CardAnnouncementAction
    
    let appearanceRules: PeriodicAnnouncementAppearanceRules
    
    private let shouldBackupFunds: Bool

    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(shouldBackupFunds: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         reappearanceTimeInterval: TimeInterval,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldBackupFunds = shouldBackupFunds
        recorder = AnnouncementRecorder(cache: cacheSuite)
        appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.dismiss = dismiss
        self.action = action
    }
}

