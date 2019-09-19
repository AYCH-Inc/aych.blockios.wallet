//
//  VerifyIdentityAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Verify identity announcement
final class VerifyIdentityAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.IdentityVerification.ctaButton
        )
        button.tapRelay
            .bind { [unowned self] in
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-v"),
            title: LocalizationConstants.AnnouncementCards.IdentityVerification.title,
            description: LocalizationConstants.AnnouncementCards.IdentityVerification.description,
            buttons: [button],
            dismissState: .dismissible {
                self.markRemoved()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        guard isCompletingKyc else {
            return false
        }
        guard !user.isSunriverAirdropRegistered else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.verifyIdentity
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let user: NabuUserSunriverAirdropRegistering
    private let isCompletingKyc: Bool
    
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(user: NabuUserSunriverAirdropRegistering,
         isCompletingKyc: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.recorder = AnnouncementRecorder(cache: cacheSuite)
        self.dismiss = dismiss
        self.action = action
        
        self.user = user
        self.isCompletingKyc = isCompletingKyc
    }
}
