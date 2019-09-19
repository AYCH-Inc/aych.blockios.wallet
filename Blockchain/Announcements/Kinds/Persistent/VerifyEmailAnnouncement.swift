//
//  VerifyEmailAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

/// Verify email announcement is a persistent announcement that should persist
/// as long as the user email is not verified.
final class VerifyEmailAnnouncement: PersistentAnnouncement & ActionableAnnouncement {

    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.VerifyEmail.ctaButton
        )
        button.tapRelay
            .bind { [unowned self] in
                self.action()
            }
            .disposed(by: disposeBag)
        
        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-email"),
            title: LocalizationConstants.AnnouncementCards.VerifyEmail.title,
            description: LocalizationConstants.AnnouncementCards.VerifyEmail.description,
            buttons: [button],
            dismissState: .undismissible
        )
    }
    
    var shouldShow: Bool {
        return !isEmailVerified
    }
    
    let type = AnnouncementType.verifyEmail
    
    let action: CardAnnouncementAction
    
    private let isEmailVerified: Bool
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(isEmailVerified: Bool,
         action: @escaping CardAnnouncementAction) {
        self.isEmailVerified = isEmailVerified
        self.action = action
    }
}

