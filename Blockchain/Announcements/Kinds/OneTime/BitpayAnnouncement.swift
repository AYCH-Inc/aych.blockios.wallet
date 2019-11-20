//
//  BitpayAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

/// This announcement introduces Bitpay
final class BitpayAnnouncement: OneTimeAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(
                name: "card-icon-bitpay",
                size: CGSize(width: 115, height: 40)
            ),
            description: LocalizationConstants.AnnouncementCards.Bitpay.description,
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
        return !isDismissed
    }
    
    let type = AnnouncementType.bitpay
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    private let errorRecorder: ErrorRecording

    // MARK: - Setup
    
    init(cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction) {
        self.errorRecorder = errorRecorder
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
    }
}
