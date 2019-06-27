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

class EthereumAPIClientMock: EthereumAPIClientAPI {
    var lastPushedTransaction: EthereumTransactionFinalised?
    var pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: "txHash"))
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse> {
        lastPushedTransaction = transaction
        return pushTransactionValue
    }
    
    var accountBalanceValue = Single.just(CryptoValue.createFromMajorValue(string: "2.0", assetType: .ethereum)!)
    var address: String = ""
    func fetchBalance(from address: String) -> Single<CryptoValue> {
        self.address = address
        return accountBalanceValue
    }
}

class EthereumFeeServiceMock: EthereumFeeServiceAPI {
    
    var feesValue = Single.just(EthereumTransactionFee.default)
    var fees: Single<EthereumTransactionFee> {
        return feesValue
    }
}
