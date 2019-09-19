//
//  SideMenuPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit
import RxCocoa

/// Protocol definition for a view that displays a list of
/// SideMenuItem objects.
protocol SideMenuView: class {
    func setMenu(items: [SideMenuItem])
    func presentSheet(viewModel: IntroductionSheetViewModel)
}

/// Presenter for the side menu of the app. This presenter
/// will handle the logic as to what side menu items should be
/// presented in the SideMenuView.
class SideMenuPresenter {
    
    // MARK: Public Properties
    
    var presentationEvent: Driver<[SideMenuItem]> {
        return introductionRelay.map { [weak self] in
            switch $0 {
            case .pulse(let model):
                return self?.menuItems(model.action) ?? []
            case .sheet(let model):
                self?.view?.presentSheet(viewModel: model)
                return self?.menuItems() ?? []
            case .none:
                return self?.menuItems() ?? []
            }
            }.asDriver(onErrorJustReturn: menuItems())
    }
    
    var itemSelection: Driver<SideMenuItem> {
        /// This should never throw an error.
        return itemSelectionRelay.asDriver(onErrorJustReturn: .settings)
    }

    private weak var view: SideMenuView?
    private var introductionSequence = WalletIntroductionSequence()
    private let interactor: WalletIntroductionInteractor
    private let introductionRelay = PublishRelay<WalletIntroductionEventType>()
    private let itemSelectionRelay = PublishRelay<SideMenuItem>()
    
    // MARK: - Services
    
    private let wallet: Wallet
    private let walletService: WalletService
    private let pitConfiguration: AppFeatureConfiguration
    private let recorder: AnalyticsEventRecording
    private let disposeBag = DisposeBag()
    private var disposable: Disposable?

    init(
        view: SideMenuView,
        wallet: Wallet = WalletManager.shared.wallet,
        walletService: WalletService = WalletService.shared,
        pitConfiguration: AppFeatureConfiguration = AppFeatureConfigurator.shared.configuration(for: .pitLinking),
        onboardingSettings: BlockchainSettings.Onboarding = .shared,
        recorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared
    ) {
        self.view = view
        self.wallet = wallet
        self.walletService = walletService
        self.pitConfiguration = pitConfiguration
        self.interactor = WalletIntroductionInteractor(onboardingSettings: onboardingSettings, screen: .sideMenu)
        self.recorder = recorder
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func loadSideMenu() {
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
    
    /// The only reason this is here is for handling the pulse that
    /// is displayed on `buyBitcoin`.
    func onItemSelection(_ item: SideMenuItem) {
        guard case let .buyBitcoin(action) = item else {
            itemSelectionRelay.accept(item)
            return
        }
        guard let block = action else {
            itemSelectionRelay.accept(item)
            return
        }
        block()
    }
    
    private func startingWithLocation(_ location: WalletIntroductionLocation) -> [WalletIntroductionEvent] {
        let screen = location.screen
        guard screen == .sideMenu else { return [] }
        return buySellEvents()
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

    private func menuItems(_ pulseAction: SideMenuItem.PulseAction? = nil) -> [SideMenuItem] {
        var items: [SideMenuItem] = [.accountsAndAddresses]
        
        if wallet.isLockboxEnabled() {
            items.append(.lockbox)
        }
        
        if wallet.didUpgradeToHd() {
            items.append(.backup)
        } else {
            items.append(.upgrade)
        }
        
        if wallet.isBuyEnabled() {
            items.append(.buyBitcoin(pulseAction))
        }
        
        items += [.support, .settings]
        
        if pitConfiguration.isEnabled {
            items.append(.pit)
        }
        
        return items
    }
    
    // MARK: `[WalletIntroductionEvent]`
    
    private func buySellEvents() -> [WalletIntroductionEvent] {
        return [buy, buyDescription]
    }
}

extension SideMenuPresenter {
    var buy: BuySellWalletIntroductionEvent {
        return BuySellWalletIntroductionEvent(selection: triggerNextStep)
    }
    
    var buyDescription: BuySellDescriptionIntroductionEvent {
        return BuySellDescriptionIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            /// The closure has been executed, so we pass in `nil` here.
            /// the `next` step will cause the `tableView` to reload.
            self.itemSelectionRelay.accept(.buyBitcoin(nil))
            self.triggerNextStep()
        })
    }
}
