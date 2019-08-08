//
//  AnnouncementPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformUIKit
import PlatformKit

// Priority of announcements
// 1. PIT linking
// 2. PAX
// 3. Swap
// 4. Coinify
// 5. Airdrop + KYC cards - several
// 6. Welcome cards - 3 cards

// TODO: ObjC - Remove ObjC semantics when transitioning `CardsViewController` to `Swift`
// TODO: Tests - Create a protocol for tests, and inject protocol dependencies.

/// Describes the announcement visual. Plays as a presenter / provide for announcements,
/// By creating a list of pending announcements, on which subscribers can be informed.
@objc
final class AnnouncementPresenter: NSObject {
    
    // MARK: Services
    
    private let appCoordinator: AppCoordinator
    private let featureConfigurator: FeatureConfiguring
    private let kycCoordinator: KYCCoordinator
    private let onboardingSettings: BlockchainSettings.Onboarding
    private let appSettings: BlockchainSettings.App
    private let pitCoordinator: PitCoordinator
    private let wallet: Wallet
    private let announcementHandler: AnnouncementCardActionHandler
    private let kycSettings: KYCSettingsAPI
    
    private let interactor: AnnouncementInteracting
    
    /// In-memory cache suite for announcements
    private let memoryCacheSuite = MemoryCacheSuite()
    
    // MARK: - Announcements
    
    private var announcements = AnnouncementSequence()
    
    // MARK: - Rx

    /// Returns a driver with `.none` as default value for announcement action
    /// Scheduled on be executed on main scheduler, its resources are shared and it remembers the last value.
    var announcement: Driver<AnnouncementDisplayAction> {
        return announcementRelay.asDriver(onErrorJustReturn: .none)
    }
    
    private let announcementRelay = PublishRelay<AnnouncementDisplayAction>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: AnnouncementInteracting = AnnouncementInteractor(),
         featureConfigurator: FeatureConfiguring = AppFeatureConfigurator.shared,
         appCoordinator: AppCoordinator = .shared,
         pitCoordinator: PitCoordinator = .shared,
         kycCoordinator: KYCCoordinator = .shared,
         kycSettings: KYCSettingsAPI = KYCSettings.shared,
         onboardingSettings: BlockchainSettings.Onboarding = .shared,
         appSettings: BlockchainSettings.App = .shared,
         wallet: Wallet = WalletManager.shared.wallet,
         announcementHandler: AnnouncementCardActionHandler = AnnouncementCardActionHandler()) {
        self.interactor = interactor
        self.appCoordinator = appCoordinator
        self.pitCoordinator = pitCoordinator
        self.kycCoordinator = kycCoordinator
        self.kycSettings = kycSettings
        self.featureConfigurator = featureConfigurator
        self.onboardingSettings = onboardingSettings
        self.appSettings = appSettings
        self.wallet = wallet
        self.announcementHandler = announcementHandler
    }
    
    /// Refreshes announcements on demand
    func refresh() {
        interactor.preliminaryData
            .map { [weak self] data -> [Announcement] in
                self?.computeAnnouncements(using: data) ?? []
            }
            .subscribe(onSuccess: { [weak self] announcements in
                self?.execute(announcements: announcements)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.execute(announcements: [self.welcomeAnnouncement])
            })
            .disposed(by: disposeBag)
    }
    
    private func execute(announcements: [Announcement]) {
        self.announcements.reset(to: announcements)
        triggerNextAnnouncement()
    }
    
    /// Computes announcements in the following order
    private func computeAnnouncements(using data: AnnouncementPreliminaryData) -> [Announcement] {
        return [
            pitLinkingAnnouncement,
            pax,
            swap(using: data),
            coinifyKyc(tiers: data.tiers),
            uploadDocuments(user: data.user),
            continueKyc(using: data.user),
            completeProfile(tiers: data.tiers),
            airdropRegistration(using: data),
            joinStellarAirdropWhitelist,
            welcomeAnnouncement
        ]
    }
    
    // MARK: - Accessors
    
    /// Hides whichever announcement is now displaying
    private func hideAnnouncement() {
        announcementRelay.accept(.hide)
    }
    
    /// Triggers the next announcement if available
    private func triggerNextAnnouncement() {
        guard let next = announcements.next() else {
            return
        }
        announcementRelay.accept(.show(next.type))
    }
}

// MARK: - Computes announcements

extension AnnouncementPresenter {
    
    // MARK: Alert Announcements
    
    /// Computes Airdrop Registration alert announcement
    private func airdropRegistration(using data: AnnouncementPreliminaryData) -> Announcement {
        return AirdropRegistrationAnnouncement(
            user: data.user,
            tiers: data.tiers,
            approve: announcementHandler.stellarModalPromptForAirdropRegistrationActionTapped
        )
    }
    
    /// Computes Coinify KYC alert announcement
    private func coinifyKyc(tiers: KYCUserTiersResponse) -> Announcement {
        let coinifyConfig = featureConfigurator.configuration(for: .notifyCoinifyUserToKyc)
        return CoinifyKycAnnouncement(
            configuration: coinifyConfig,
            tiers: tiers,
            wallet: wallet,
            dismissRecorder: AnnouncementDismissRecorder(cache: memoryCacheSuite),
            confirm: announcementHandler.coinifyKycActionTapped,
            learnMore: { [weak self] in
                guard let self = self else { return }
                UIApplication.shared.openSafariViewController(
                    url: Constants.Url.requiredIdentityVerificationURL,
                    presentingViewController: self.appCoordinator.tabControllerManager.tabViewController
                )
            }
        )
    }
    
    // MARK: - Card Accouncements
    
    // Computes Wallet-PIT linking announcement
    private var pitLinkingAnnouncement: PitLinkingAnnouncement {
        let pitAnnouncementConfig = featureConfigurator.configuration(for: .pitAnnouncement)
        return PitLinkingAnnouncement(
            config: pitAnnouncementConfig,
            dismiss: hideAnnouncement,
            approve: pitCoordinator.start
        )
    }
    
    // Computes Welcome Announcement
    private var welcomeAnnouncement: Announcement {
        return WelcomeAnnouncement()
    }
    
    // Computes Join Stellar Airedrop Whitelist card announcement
    private var joinStellarAirdropWhitelist: Announcement {
        let stellarAirdropPopupConfig = featureConfigurator.configuration(for: .stellarAirdropPopup)
        let airdropConfig = featureConfigurator.configuration(for: .stellarAirdrop)
        return JoinStellarAirdropWhitelistAnnouncement(
            airdropConfig: airdropConfig,
            popupConfig: stellarAirdropPopupConfig,
            appSettings: appSettings,
            dismiss: hideAnnouncement,
            approve: announcementHandler.stellarAirdropCardActionTapped
        )
    }
    
    // Computes Complete Profile card announcement
    private func completeProfile(tiers: KYCUserTiersResponse) -> Announcement {
        let airdropConfig = featureConfigurator.configuration(for: .stellarAirdrop)
        return CompleteProfileAnnouncement(
            onboardingSettings: onboardingSettings,
            appSettings: appSettings,
            airdropConfig: airdropConfig,
            tiers: tiers,
            dismiss: hideAnnouncement,
            approve: announcementHandler.stellarAirdropCardActionTapped
        )
    }
    
    /// Computes Upload Documents card announcement
    private func uploadDocuments(user: NabuUser) -> Announcement {
        return UploadDocumentsAnnouncement(
            user: user,
            dismiss: hideAnnouncement,
            approve: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycCoordinator.start(from: self.appCoordinator.tabControllerManager, tier: tier)
            }
        )
    }
    
    /// Computes Continue Kyc card announcement
    private func continueKyc(using user: NabuUser) -> Announcement {
        return ContinueKycAnnouncement(
            user: user,
            isCompletingKyc: kycSettings.isCompletingKyc,
            dismiss: hideAnnouncement,
            approve: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycCoordinator.start(from: self.appCoordinator.tabControllerManager, tier: tier)
            }
        )
    }
    
    /// Computes Swap card announcement
    private func swap(using data: AnnouncementPreliminaryData) -> Announcement {
        return SwapAnnouncement(
            isSwapEnabled: data.isSwapEnabled,
            hasTrades: data.hasTrades,
            dismiss: hideAnnouncement,
            approve: appCoordinator.switchTabToSwap
        )
    }
    
    /// Computes PAX card announcement
    private var pax: Announcement {
        return PAXAnnouncement(
            dismiss: hideAnnouncement,
            approve: appCoordinator.switchTabToSwap
        )
    }
}
