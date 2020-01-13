//
//  EthereumWalletBridgeMock.swift
//  EthereumKitTests
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import BigInt
import PlatformKit
@testable import EthereumKit

enum EthereumWalletBridgeMockError: Error {
    case mockError
}

class EthereumWalletBridgeMock: EthereumWalletBridgeAPI, EthereumWalletAccountBridgeAPI, MnemonicAccessAPI, PasswordAccessAPI {
    
    var isWaitingOnTransactionValue = Single.just(false)
    var isWaitingOnTransaction: Single<Bool> {
        return isWaitingOnTransactionValue
    }
    
    var historyValue = Single.just(())
    var history: Single<Void> {
        return historyValue
    }
    
    func fetchHistory() -> Single<Void> {
        history
    }
    
    var fetchBalanceValue: Single<CryptoValue> = Single.just(CryptoValue.etherFromMajor(string: "2.0")!)
    var fetchBalance: Single<CryptoValue> {
        return fetchBalanceValue
    }
    
    var balanceValue: Single<CryptoValue> = Single.just(CryptoValue.etherFromMajor(string: "2.0")!)
    var balance: Single<CryptoValue> {
        return balanceValue
    }
    
    var balanceObservable: Observable<CryptoValue> {
        return balance.asObservable()
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    var nameValue: Single<String> = Single.just("My Ether Wallet")
    var name: Single<String> {
        return nameValue
    }
    
    var addressValue: Single<String> = Single.just(MockEthereumWalletTestData.account)
    var address: Single<String> {
        return addressValue
    }
    
    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var transactions: Single<[EthereumHistoricalTransaction]> {
        return transactionsValue
    }
    
    var accountValue: Single<EthereumAssetAccount> = Single.just(
        EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: "My Ether Wallet"
        )
    )
    var account: Single<EthereumAssetAccount> {
        return accountValue
    }
    
    var nonceValue = Single.just(BigUInt(9))
    var nonce: Single<BigUInt> {
        return nonceValue
    }
    
    var recordLastTransactionValue: Single<EthereumTransactionPublished> = Single<EthereumTransactionPublished>.error(EthereumKitError.unknown)
    var lastRecordedTransaction: EthereumTransactionPublished?
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        lastRecordedTransaction = transaction
        return recordLastTransactionValue
    }
    
    // MARK: - EthereumWalletAccountBridgeAPI
    
    var wallets: Single<[EthereumWalletAccount]> {
        return Single.just([])
    }
    
    func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        return Completable.empty()
    }
    
    // MARK: - MnemonicAccessAPI
    
    var mnemonic: Maybe<String> {
        return Maybe.just("")
    }
    
    var mnemonicForcePrompt: Maybe<String> {
        return Maybe.just("")
    }
    
    var mnemonicPromptingIfNeeded: Maybe<String> {
        return Maybe.just("")
    }
    
    // MARK: - PasswordAccessAPI
    
    var passwordMaybe = Maybe.just("password")
    var password: Maybe<String> {
        return passwordMaybe
    }
}
