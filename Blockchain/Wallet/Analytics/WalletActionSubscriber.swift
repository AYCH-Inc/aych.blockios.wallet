//
//  WalletActionSubscriber.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// Subscribes to events emited by `WalletActionPublisher`
class WalletActionSubscriber {

    static let shared = WalletActionSubscriber()

    private let appSettings: BlockchainSettings.App
    private let bus: WalletActionEventBus
    private let walletSettings: WalletSettingsAPI

    private var disposable: Disposable?

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        bus: WalletActionEventBus = WalletActionEventBus.shared,
        walletSettings: WalletSettingsAPI = WalletSettingsService()
    ) {
        self.appSettings = appSettings
        self.bus = bus
        self.walletSettings = walletSettings
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
        guard let guid = appSettings.guid else {
            Logger.shared.warning("Cannot update last-tx-time, guid is nil.")
            return
        }
        guard let sharedKey = appSettings.sharedKey else {
            Logger.shared.warning("Cannot update last-tx-time, sharedKey is nil.")
            return
        }
        _ = walletSettings.updateLastTxTimeToCurrentTime(guid: guid, sharedKey: sharedKey).subscribe(onCompleted: {
            Logger.shared.info("last-tx-time updated.")
        }, onError: { error in
            Logger.shared.error("Failed to update last-tx-time. Error: \(error.localizedDescription)")
        })
    }
}
