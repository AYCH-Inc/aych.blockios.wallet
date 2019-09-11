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
    var pitAddressFetcher: PitAddressFetching { get }
    var executor: SendExecuting { get }
    var exchange: SendExchangeServicing { get }
    var fee: SendFeeServicing { get }
    var balance: AccountBalanceFetching { get }
    
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
    let pitAddressFetcher: PitAddressFetching
    let executor: SendExecuting
    let exchange: SendExchangeServicing
    let fee: SendFeeServicing
    let balance: AccountBalanceFetching
    
    init(asset: AssetType) {
        self.asset = asset
        pitAddressFetcher = PitAddressFetcher()
        executor = SendExecutor(asset: asset)
        exchange = SendExchangeService(asset: asset)
        fee = SendFeeService(asset: asset)
        sourceAccountState = SendSourceAccountStateService(asset: asset)
        switch asset {
        case .ethereum:
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
