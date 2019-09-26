//
//  PITLinkingAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Card announcement for Wallet-PIT linking
final class PITLinkingAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Pit.ctaButton,
            background: .pitTheme
        )
        button.tapRelay
            .bind { [unowned self] in
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.analyticsRecorder.record(event: AnalyticsEvents.PIT.AnnouncementTapped())
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)
        
        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-pit"),
            title: LocalizationConstants.AnnouncementCards.Pit.title,
            description: LocalizationConstants.AnnouncementCards.Pit.description,
            buttons: [button],
            dismissState: .dismissible {
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: {
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }
    
    var shouldShow: Bool {
        guard shouldShowPitAnnouncement else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.pitLinking
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let disposeBag = DisposeBag()

    private let shouldShowPitAnnouncement: Bool
    
    // MARK: - Setup
    
    init(shouldShowPitAnnouncement: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldShowPitAnnouncement = shouldShowPitAnnouncement
        self.recorder = AnnouncementRecorder(cache: cacheSuite)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
