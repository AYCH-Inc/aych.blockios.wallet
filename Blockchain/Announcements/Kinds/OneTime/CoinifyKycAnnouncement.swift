//
//  CoinifyKycAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

/// An announcements that is a part of the KYC process. Encourages the user
/// to complete the KYC process and submit his documents.
final class CoinifyKycAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let primaryButton = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.CoinifyKyc.ctaButton
        )
        primaryButton.tapRelay
            .bind { [unowned self] in
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)
        
        return AnnouncementCardViewModel(
            image: AnnouncementCardViewModel.Image(name: "card-icon-v"),
            title: LocalizationConstants.AnnouncementCards.CoinifyKyc.title,
            description: LocalizationConstants.AnnouncementCards.CoinifyKyc.description,
            buttons: [primaryButton],
            dismissState: .dismissible {
                self.markRemoved()
                self.dismiss()
            }
        )
    }
    
    var shouldShow: Bool {
        guard configuration.isEnabled else {
            return false
        }
        guard tiers.canCompleteTier2 else {
            return false
        }
        // TODO: This calls JS. convert to native
        guard wallet.isCoinifyTrader() else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.coinifyKyc
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    let action: CardAnnouncementAction
    
    private let configuration: AppFeatureConfiguration
    private let tiers: KYCUserTiersResponse
    private let wallet: Wallet

    private let disposeBag = DisposeBag()
    
    // MARK: - Setup

    init(configuration: AppFeatureConfiguration,
         tiers: KYCUserTiersResponse,
         wallet: Wallet,
         cacheSuite: CacheSuite = UserDefaults.standard,
         reappearanceTimeInterval: TimeInterval,
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.configuration = configuration
        self.tiers = tiers
        self.wallet = wallet
        self.recorder = AnnouncementRecorder(cache: cacheSuite)
        self.dismiss = dismiss
        self.action = action
    }
}
