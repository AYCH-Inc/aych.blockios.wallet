//
//  KycBlockstackAirdropAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Card announcement for blockstack airdrop announcement
final class KycBlockstackAirdropAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.BlockstackAirdrop
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        var button = ButtonViewModel(
            accessibility: .init(id: .value(Accessibility.Identifier.General.mainCTAButton))
        )
        button.theme = ButtonViewModel.Theme(
            backgroundColor: .airdropCTAButton,
            contentColor: .white,
            text: LocalizedString.ctaButton
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
            background: .init(color: .white, imageName: "card-background-stx-airdrop"),
            image: .init(name: "card-icon-stx-airdrop"),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
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
        guard canCompleteTier2 else { return false }
        return !isDismissed
    }
    
    let type = AnnouncementType.kycBlockstackAirdrop
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let disposeBag = DisposeBag()
    
    private let canCompleteTier2: Bool
    
    // MARK: - Setup
    
    init(canCompleteTier2: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         variantFetcher: FeatureFetching = AppFeatureConfigurator.shared,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.canCompleteTier2 = canCompleteTier2
        self.recorder = AnnouncementRecorder(cache: cacheSuite)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
