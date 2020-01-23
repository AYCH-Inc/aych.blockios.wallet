//
//  WalletActionSubscriber.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

/// Subscribes to events emited by `WalletActionPublisher`
class WalletActionSubscriber {

    static let shared = WalletActionSubscriber()

    private let appSettings: BlockchainSettings.App
    private let bus: WalletActionEventBus
    private let lastTransactionUpdateService: LastTransactionSettingsUpdateServiceAPI

    private var disposable: Disposable?

    private let disposeBag = DisposeBag()
    
    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        bus: WalletActionEventBus = WalletActionEventBus.shared,
        lastTransactionUpdateService: LastTransactionSettingsUpdateServiceAPI = UserInformationServiceProvider.default.settings
    ) {
        self.appSettings = appSettings
        self.bus = bus
        self.lastTransactionUpdateService = lastTransactionUpdateService
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    /// Invoke this method to start listening to `WalletAction` objects emitted by `WalletActionPublisher`
    func subscribe() {
        disposable = bus.events.debug().subscribe(onNext: {
            self.onEventReceived($0)
        })
    }

    // MARK: - Private

    private func onEventReceived(_ event: WalletActionEvent) {
        switch event.action {
        case .sendCrypto:
            onSendCrypto()
        case .buyCryptoWithFiat:
            onBuyCryptoWithFiat()
        case .sellCryptoToFiat:
            onSellCryptoWithFiat()
        case .receiveCrypto:
            // Do nothing
            return
        }
    }

    private func onSendCrypto() {
        updateLastTxTime()
    }

    private func onBuyCryptoWithFiat() {
        updateLastTxTime()
    }

    private func onSellCryptoWithFiat() {
        updateLastTxTime()
    }

    private func updateLastTxTime() {
        lastTransactionUpdateService.updateLastTransaction()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
