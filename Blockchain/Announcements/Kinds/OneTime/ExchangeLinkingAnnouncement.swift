//
//  ExchangeLinkingAnnouncement.swift
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

/// Card announcement for Wallet-Exchange linking
final class ExchangeLinkingAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Exchange.ctaButton,
            background: .exchangeAnnouncementButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Exchange.exchangeAnnouncementTapped)
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: self.disposeBag)
                    
        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "exchange-icon-small"),
            title: LocalizationConstants.AnnouncementCards.Exchange.title,
            description: LocalizationConstants.AnnouncementCards.Exchange.description,
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
        guard shouldShowExchangeAnnouncement else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.exchangeLinking
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let disposeBag = DisposeBag()

    private let shouldShowExchangeAnnouncement: Bool
    private let errorRecorder: ErrorRecording
    
    // MARK: - Setup
    
    init(shouldShowExchangeAnnouncement: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldShowExchangeAnnouncement = shouldShowExchangeAnnouncement
        self.errorRecorder = errorRecorder
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
