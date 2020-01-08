//
//  SendServiceContainer.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit

protocol SendServiceContaining {
    var asset: AssetType { get }
    var sourceAccountProvider: SendSourceAccountProviding { get }
    var sourceAccountState: SendSourceAccountStateServicing { get }
    var exchangeAddressFetcher: ExchangeAddressFetching { get }
    var executor: SendExecuting { get }
    var exchange: PairExchangeServiceAPI { get }
    var fee: SendFeeServicing { get }
    var balance: AccountBalanceFetching { get }
    var bus: WalletActionEventBus { get }
    
    /// Performs any necessary cleaning to the service layer.
    /// In order to change asset in the future, we will only replace `asset: AssetType`
    /// which will force the interaction & presentation to change accordingly.
    /// Adopting this approach, only 1 VIPER will be needed.
    func clean()
}

struct SendServiceContainer: SendServiceContaining {
    let asset: AssetType
    let sourceAccountProvider: SendSourceAccountProviding
    let sourceAccountState: SendSourceAccountStateServicing
    let exchangeAddressFetcher: ExchangeAddressFetching
    let executor: SendExecuting
    let exchange: PairExchangeServiceAPI
    let fee: SendFeeServicing
    let balance: AccountBalanceFetching
    let bus: WalletActionEventBus
    
    init(asset: AssetType) {
        self.asset = asset
        exchangeAddressFetcher = ExchangeAddressFetcher()
        executor = SendExecutor(asset: asset)
        fee = SendFeeService(asset: asset)
        sourceAccountState = SendSourceAccountStateService(asset: asset)
        bus = WalletActionEventBus()
        switch asset {
        case .ethereum:
            exchange = DataProvider.default.exchange[.ethereum]
            sourceAccountProvider = EtherSendSourceAccountProvider()
            balance = WalletManager.shared.wallet.ethereum
        case .bitcoin, .bitcoinCash, .pax, .stellar:
            fatalError("\(#function) is not implemented for \(asset)")
        }
    }
    
    func clean() {
        sourceAccountState.recalculateState()
        fee.triggerRelay.accept(Void())
        exchange.fetchTriggerRelay.accept(Void())
        executor.fetchHistoryIfNeeded()
    }
}
