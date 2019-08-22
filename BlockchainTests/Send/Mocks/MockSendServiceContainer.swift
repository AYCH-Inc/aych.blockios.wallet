//
//  MockSendServiceContainer.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

struct MockSendServiceContainer: SendServiceContaining {
    let asset: AssetType
    let sourceAccount: SendSourceAccountProviding
    let pitAddressFetcher: PitAddressFetching
    let executor: SendExecuting
    let exchange: SendExchangeServicing
    let fee: SendFeeServicing
    let balance: AccountBalanceFetching
    
    init(asset: AssetType,
         balance: CryptoValue,
         fee: CryptoValue,
         exchange: FiatValue,
         pitAddressFetchResult: Result<PitAddressFetcher.PitAddressResponseBody.State, PitAddressFetcher.FetchingError>,
         transferExecutionResult: Result<Void, Error>) {
        self.asset = asset
        pitAddressFetcher = MockPitAddressFetcher(expectedResult: pitAddressFetchResult)
        executor = MockSendExecutor(expectedResult: transferExecutionResult)
        self.exchange = MockSendExchangeService(expectedValue: exchange)
        self.fee = MockSendFeeService(expectedValue: fee)
        switch asset {
        case .ethereum:
            sourceAccount = EtherSendSourceAccountProvider()
            self.balance = MockAccountBalanceFetcher(expectedBalance: balance)
        case .bitcoin, .bitcoinCash, .pax, .stellar:
            fatalError("\(#function) is not implemented for \(asset)")
        }
    }
    
    func clean() {
        // TODO:
    }
}
