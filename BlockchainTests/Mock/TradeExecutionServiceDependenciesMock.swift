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

class TradeExecutionServiceDependenciesMock: TradeExecutionServiceDependenciesAPI {
    var assetAccountRepository: AssetAccountRepositoryAPI = AssetAccountRepositoryMock()
    var feeService: FeeServiceAPI = FeeServiceMock()
    var xlm: XLMDependenciesAPI = XLMDependenciesMock()
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

class XLMDependenciesMock: XLMDependenciesAPI {
    var accounts: StellarAccountAPI = StellarAccountMock()
    var transactionAPI: StellarTransactionAPI = StellarTransactionMock()
    var ledgerAPI: StellarLedgerAPI = StellarLedgerMock()
    var repository: StellarWalletAccountRepositoryAPI = StellarWalletAccountRepositoryMock()
    var limits: StellarTradeLimitsAPI = StellarTradeLimitsMock()
}
