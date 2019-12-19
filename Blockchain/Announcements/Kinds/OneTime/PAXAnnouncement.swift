//
//  PAXAnnouncement.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

/// Announcement that introduces PAX asset
final class PAXAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Pax.ctaButton,
            background: .paxos
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "filled_pax_small"),
            title: LocalizationConstants.AnnouncementCards.Pax.title,
            description: LocalizationConstants.AnnouncementCards.Pax.description,
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
        guard !hasTransactions else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.pax
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    let action: CardAnnouncementAction
    
    private let hasTransactions: Bool
    
    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording
    
    // MARK: - Setup

    init(hasTransactions: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.hasTransactions = hasTransactions
        self.errorRecorder = errorRecorder
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
