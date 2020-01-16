//
//  MockSendServiceContainer.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

@testable import Blockchain

struct MockSendServiceContainer: SendServiceContaining {
    let asset: AssetType
    let sourceAccountProvider: SendSourceAccountProviding
    var sourceAccountState: SendSourceAccountStateServicing
    let exchangeAddressFetcher: ExchangeAddressFetching
    let executor: SendExecuting
    let exchange: PairExchangeServiceAPI
    let fee: SendFeeServicing
    let balance: AccountBalanceFetching
    let bus: WalletActionEventBus
    
    init(asset: AssetType,
         balance: CryptoValue,
         fee: CryptoValue,
         exchange: FiatValue,
         sourceAccountStateValue: SendSourceAccountState,
         pitAddressFetchResult: Result<ExchangeAddressFetcher.AddressResponseBody.State, ExchangeAddressFetcher.FetchingError>,
         transferExecutionResult: Result<Void, Error>) {
        self.asset = asset
        exchangeAddressFetcher = MockExchangeAddressFetcher(expectedResult: pitAddressFetchResult)
        executor = MockSendExecutor(expectedResult: transferExecutionResult)
        self.exchange = MockPairExchangeService(expectedValue: exchange)
        self.fee = MockSendFeeService(expectedValue: fee)
        sourceAccountState = MockSendSourceAccountStateService(stateRawValue: sourceAccountStateValue)
        bus = WalletActionEventBus()
        switch asset {
        case .ethereum, .pax:
            sourceAccountProvider = EtherSendSourceAccountProvider()
            self.balance = MockAccountBalanceFetcher(expectedBalance: balance)
        case .bitcoin, .bitcoinCash, .stellar:
            fatalError("\(#function) is not implemented for \(asset)")
        }
    }
    
    func clean() {
        // TODO:
    }
}
