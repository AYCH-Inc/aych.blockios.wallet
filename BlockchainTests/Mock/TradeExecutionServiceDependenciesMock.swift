//
//  TradeExecutionServiceDependenciesMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import stellarsdk

@testable import Blockchain
@testable import PlatformKit
@testable import BitcoinKit
@testable import StellarKit
@testable import EthereumKit
@testable import ERC20Kit

class StellarOperationMock: StellarOperationsAPI {
    var operations: Observable<[Blockchain.StellarOperation]> = Observable.just([])
    
    func isStreaming() -> Bool {
        return true
    }
    
    func end() {
        
    }
    
    func clear() {
        
    }
}

final class PriceServiceMock: PriceServiceAPI {
    
    private let expectedResult: PriceInFiatValue
    
    init(expectedResult: PriceInFiatValue) {
        self.expectedResult = expectedResult
    }
    
    func fiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String) -> Single<PriceInFiatValue> {
        return Single.error(NSError())
        return .just(expectedResult)
    }
    
    func fiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String, timestamp: Date) -> Single<PriceInFiatValue> {
        return Single.error(NSError())
        return .just(expectedResult)
    }
}

class TradeExecutionServiceDependenciesMock: TradeExecutionServiceDependenciesAPI {
    var assetAccountRepository: Blockchain.AssetAccountRepositoryAPI = AssetAccountRepositoryMock()
    var feeService: FeeServiceAPI = FeeServiceMock()
    var stellar: StellarDependenciesAPI = StellarDependenciesMock()
    var erc20Service: AnyERC20Service<PaxToken> = AnyERC20Service<PaxToken>(PaxERC20ServiceMock())
    var erc20AccountRepository: AnyERC20AssetAccountRepository<PaxToken> = AnyERC20AssetAccountRepository<PaxToken>(ERC20AssetAccountRepositoryMock())
    var ethereumWalletService: EthereumWalletServiceAPI = EthereumWalletServiceMock()
}

class FeeServiceMock: FeeServiceAPI {
    var bitcoin: Single<BitcoinTransactionFee> = Single.error(NSError())
    var ethereum: Single<EthereumTransactionFee> = Single.error(NSError())
    var stellar: Single<StellarTransactionFee> = Single.error(NSError())
    var bitcoinCash: Single<BitcoinCashTransactionFee> = Single.error(NSError())
}

class StellarDependenciesMock: StellarDependenciesAPI {
    var accounts: StellarAccountAPI = StellarAccountMock()
    var ledger: StellarLedgerAPI = StellarLedgerMock()
    var operation: StellarOperationsAPI = StellarOperationMock()
    var transaction: StellarTransactionAPI = StellarTransactionMock()
    var limits: StellarTradeLimitsAPI = StellarTradeLimitsMock()
    var repository: StellarWalletAccountRepositoryAPI = StellarWalletAccountRepositoryMock()
    var prices: PriceServiceAPI = PriceServiceMock(expectedResult: PriceInFiat.empty.toPriceInFiatValue(currencyCode: "USD"))
    var walletActionEventBus: WalletActionEventBus = WalletActionEventBus()
    var feeService: StellarFeeServiceAPI = StellarFeeServiceMock()
}
