//
//  AirdropRegisteredAnnouncementMini.swift
//  Blockchain
//
//  Created by Jack on 28/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// Airdrop Registered announcemnt is a persistent announcement that should persist until
/// removed from remote config
final class AirdropRegisteredAnnouncementMini: PersistentAnnouncement {
    
    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.BlockstackAirdropRegisteredMini

    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            type: type,
            presentation: .mini,
            background: .init(color: .white, imageName: "card-background-stx-airdrop"),
            image: .init(name: "card-icon-stx-airdrop"),
            title: LocalizedString.title,
            description: LocalizedString.description,
            recorder: errorRecorder,
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }
    
    var shouldShow: Bool {
        return airdropRegistered
    }
    
    let type = AnnouncementType.verifyEmail
    let analyticsRecorder: AnalyticsEventRecording
    
    private let airdropRegistered: Bool
    private let errorRecorder: ErrorRecording

    // MARK: - Setup
    
    init(airdropRegistered: Bool,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder()) {
        self.airdropRegistered = airdropRegistered
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
    }
}
