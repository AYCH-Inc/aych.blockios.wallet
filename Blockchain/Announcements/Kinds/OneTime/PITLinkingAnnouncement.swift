//
//  PITLinkingAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

/// Card announcement for Wallet-PIT linking
final class PITLinkingAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Pit.ctaButton,
            background: .pitTheme
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.PIT.AnnouncementTapped())
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: self.disposeBag)
                    
        let description: String
        switch variant {
        case .variantB:
            description = LocalizationConstants.AnnouncementCards.Pit.variantBDescription
        default: // Control group is assumed to be `A` which is also the default
            description = LocalizationConstants.AnnouncementCards.Pit.variantADescription
        }
        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "card-icon-pit"),
            title: LocalizationConstants.AnnouncementCards.Pit.title,
            description: description,
            buttons: [button],
            recorder: errorRecorder,
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
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
    private let variant: FeatureTestingVariant
    private let errorRecorder: ErrorRecording
    
    // MARK: - Setup
    
    init(shouldShowPitAnnouncement: Bool,
         variant: FeatureTestingVariant,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         variantFetcher: FeatureFetching = AppFeatureConfigurator.shared,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldShowPitAnnouncement = shouldShowPitAnnouncement
        self.errorRecorder = errorRecorder
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.variant = variant
        self.dismiss = dismiss
        self.action = action
    }
}
