//
//  WalletIntroductionPresenter.swift
//  Blockchain
//
//  Created by AlexM on 8/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

// A `Presentation` event that is built from a `WalletIntroductionEventType`
// and consumed by a `UIViewController`
enum WalletIntroductionPresentationEvent {
    case showPulse(WalletIntroductionPulseViewModel)
    case presentSheet(IntroductionSheetViewModel)
    case introductionComplete
}

/// `WalletIntroductionPresenter` is used on the `TabViewController`.
@objc
final class WalletIntroductionPresenter: NSObject {
    
    /// Returns a `WalletIntroductionPresentationEvent` that the `UIViewController` can respond to.
    var introductionEvent: Driver<WalletIntroductionPresentationEvent> {
        return introductionRelay.map {
            switch $0 {
            case .pulse(let model):
                return .showPulse(model)
            case .sheet(let model):
                return .presentSheet(model)
            case .none:
                return .introductionComplete
            }
            }.asDriver(onErrorJustReturn: .introductionComplete)
    }
    
    // The current introduction sequence.
    private var introductionSequence = WalletIntroductionSequence()
    
    private let wallet: Wallet
    private let interactor: WalletIntroductionInteractor
    private let recorder: AnalyticsEventRecording
    private let screen: WalletIntroductionLocation.Screen
    private let onboardingSettings: BlockchainSettings.Onboarding
    private let introductionRelay = PublishRelay<WalletIntroductionEventType>()
    private let disposeBag = DisposeBag()
    
    init(
        onboardingSettings: BlockchainSettings.Onboarding = .shared,
        screen: WalletIntroductionLocation.Screen,
        wallet: Wallet = WalletManager.shared.wallet,
        recorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared
        ) {
        self.onboardingSettings = onboardingSettings
        self.screen = screen
        self.interactor = WalletIntroductionInteractor(onboardingSettings: onboardingSettings, screen: screen)
        self.wallet = wallet
        self.recorder = recorder
    }
    
    func start() {
        interactor.startingLocation
            .map { [weak self] location -> [WalletIntroductionEvent] in
                return self?.startingWithLocation(location) ?? []
            }
            .subscribe(onSuccess: { [weak self] events in
                guard let self = self else { return }
                self.execute(events: events)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.introductionRelay.accept(.none)
            })
        .disposed(by: disposeBag)
    }
    
    private func triggerNextStep() {
        guard let next = introductionSequence.next() else { return }
        /// We track all introduction events that have an analyticsKey.
        /// This happens on presentation. 
        if let trackable = next as? WalletIntroductionAnalyticsEvent {
            recorder.record(event: trackable.eventType)
        }
        introductionRelay.accept(next.type)
    }
    
    private func execute(events: [WalletIntroductionEvent]) {
        introductionSequence.reset(to: events)
        triggerNextStep()
    }
    
    private func startingWithLocation(_ location: WalletIntroductionLocation) -> [WalletIntroductionEvent] {
        let screen = location.screen
        let position = location.position
        guard screen == .dashboard else { return [] }
        switch position {
        case .home:
            return homeEvents() + sendEvents() + requestEvents() + swapEvents()
        case .send:
            return sendEvents() + requestEvents() + swapEvents()
        case .request:
            return requestEvents() + swapEvents()
        case .swap:
            return swapEvents()
        case .buySell:
            return []
        }
    }
    
    // MARK: `[WalletIntroductionEvent]` 
    
    private func homeEvents() -> [WalletIntroductionEvent] {
        return [home, homeDescription]
    }
    
    private func sendEvents() -> [WalletIntroductionEvent] {
        return [send, sendDescription]
    }
    
    private func requestEvents() -> [WalletIntroductionEvent] {
        return [request, requestDescription]
    }
    
    private func swapEvents() -> [WalletIntroductionEvent] {
        return [swap, swapDescription]
    }
}

extension WalletIntroductionPresenter {
    private var home: HomeWalletIntroductionEvent {
        return HomeWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            AppCoordinator.shared.tabControllerManager.dashBoardClicked(nil)
            self.triggerNextStep()
        })
    }
    
    private var homeDescription: HomeDescriptionWalletIntroductionEvent {
        return HomeDescriptionWalletIntroductionEvent(selection: triggerNextStep)
    }
    
    private var send: SendWalletIntroductionEvent {
        return SendWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            AppCoordinator.shared.tabControllerManager.sendCoinsClicked(nil)
            self.triggerNextStep()
        })
    }
    
    private var sendDescription: SendDescriptionIntroductionEvent {
        return SendDescriptionIntroductionEvent(selection: triggerNextStep)
    }
    
    private var request: RequestWalletIntroductionEvent {
        return RequestWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            AppCoordinator.shared.tabControllerManager.receiveCoinClicked(nil)
            self.triggerNextStep()
        })
    }
    
    private var requestDescription: RequestDescriptionIntroductionEvent {
        return RequestDescriptionIntroductionEvent(selection: triggerNextStep)
    }
    
    private var swap: SwapWalletIntroductionEvent {
        return SwapWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            AppCoordinator.shared.tabControllerManager.swapTapped(nil)
            self.triggerNextStep()
        })
    }
    
    private var swapDescription: SwapDescriptionIntroductionEvent {
        return SwapDescriptionIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            self.triggerNextStep()
            // If `Buy` isn't enabled, then we don't need to open the side menu.
            guard self.wallet.isBuyEnabled() else { return }
            AppCoordinator.shared.toggleSideMenu()
        })
    }
}
