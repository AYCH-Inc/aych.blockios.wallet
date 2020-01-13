//
//  EthereumWalletAccountRepositoryMock.swift
//  EthereumKitTests
//
//  Created by Jack on 10/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import web3swift
import BigInt
import PlatformKit
@testable import EthereumKit

class EthereumWalletAccountRepositoryMock: EthereumWalletAccountRepositoryAPI {
    var keyPairValue = Maybe.just(MockEthereumWalletTestData.keyPair)
    var keyPair: PrimitiveSequence<MaybeTrait, EthereumKeyPair> {
        return keyPairValue
    }
    
    static let ethereumWalletAccount = EthereumWalletAccount(
        index: 0,
        publicKey: "",
        label: "",
        archived: false
    )
    
    var defaultAccountValue: EthereumWalletAccount? = ethereumWalletAccount
    var defaultAccount: EthereumWalletAccount? {
        return defaultAccountValue
    }
    
    var initializeMetadataMaybeValue = Maybe.just(ethereumWalletAccount)
    func initializeMetadataMaybe() -> Maybe<EthereumWalletAccount> {
        return initializeMetadataMaybeValue
    }
    
    var accountsValue: [EthereumWalletAccount] = []
    func accounts() -> [EthereumWalletAccount] {
        return accountsValue
    }
}

enum EthereumAPIClientMockError: Error {
    case mockError
}

class EthereumAPIClientMock: EthereumKit.APIClientProtocol {
    
    var balanceDetailsValue = Single<BalanceDetailsResponse>.error(EthereumAPIClientMockError.mockError)
    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse> {
        return balanceDetailsValue
    }
    
    var latestBlockValue: Single<LatestBlockResponse> = Single.error(EthereumAPIClientMockError.mockError)
    var latestBlock: Single<LatestBlockResponse> {
        return latestBlockValue
    }
    
    var lastAccountForAddress: String?
    var accountForAddressValue: Single<EthereumAccountResponse> = Single.error(EthereumAPIClientMockError.mockError)
    func account(for address: String) -> Single<EthereumAccountResponse> {
        lastAccountForAddress = address
        return accountForAddressValue
    }
    
    var lastTransactionsForAccount: String?
    var transactionsForAccountValue: Single<[EthereumHistoricalTransactionResponse]> = Single.just([])
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]> {
        lastTransactionsForAccount = account
        return transactionsForAccountValue
    }
    
    var lastPushedTransaction: EthereumTransactionFinalised?
    var pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: "txHash"))
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse> {
        lastPushedTransaction = transaction
        return pushTransactionValue
    }
}

class EthereumFeeServiceMock: EthereumFeeServiceAPI {
    
    var feesValue = Single.just(EthereumTransactionFee.default)
    var fees: Single<EthereumTransactionFee> {
        return feesValue
    }
}
