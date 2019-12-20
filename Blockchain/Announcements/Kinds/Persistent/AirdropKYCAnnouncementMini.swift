//
//  AirdropKYCAnnouncementMini.swift
//  Blockchain
//
//  Created by Jack on 29/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

/// Mini card announcement for blockstack airdrop announcement
final class AirdropKYCAnnouncementMini: PersistentAnnouncement & ActionableAnnouncement {
    
    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.BlockstackAirdropMini
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel(
            accessibility: .init(id: .value(Accessibility.Identifier.General.mainCTAButton))
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.action()
            }
            .disposed(by: disposeBag)
                    
        return AnnouncementCardViewModel(
            type: .blockstackAirdropMini,
            presentation: .mini,
            background: .init(color: .white, imageName: "card-background-stx-airdrop"),
            image: .init(name: "card-icon-stx-airdrop"),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [ button ],
            recorder: errorRecorder,
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }
    
    var shouldShow: Bool {
        return canCompleteTier2 && !isAirdropRegistered
    }
    
    let type = AnnouncementType.blockstackAirdropMini
    let analyticsRecorder: AnalyticsEventRecording
    
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let canCompleteTier2: Bool
    private let isAirdropRegistered: Bool
    
    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording

    // MARK: - Setup
    
    init(canCompleteTier2: Bool,
         isAirdropRegistered: Bool,
         cacheSuite: CacheSuite = UserDefaults.standard,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         variantFetcher: FeatureFetching = AppFeatureConfigurator.shared,
         action: @escaping CardAnnouncementAction) {
        self.canCompleteTier2 = canCompleteTier2
        self.isAirdropRegistered = isAirdropRegistered
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.action = action
    }
}
