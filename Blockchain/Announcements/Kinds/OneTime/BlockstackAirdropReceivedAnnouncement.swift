//
//  BlockstackAirdropReceivedAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

/// Card announcement for blockstack airdrop announcement in case the user has received the airdrop
final class BlockstackAirdropReceivedAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.BlockstackAirdropReceived
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(with: LocalizedString.ctaButton)
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
            image: .init(name: "blockstack_icon"),
            title: LocalizedString.title,
            description: LocalizedString.description,
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
        guard hasReceivedBlockstackAirdrop else { return false }
        return !isDismissed
    }
    
    let type = AnnouncementType.blockstackAirdropReceived
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let hasReceivedBlockstackAirdrop: Bool
    
    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording

    // MARK: - Setup
    
    init(hasReceivedBlockstackAirdrop: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.hasReceivedBlockstackAirdrop = hasReceivedBlockstackAirdrop
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
