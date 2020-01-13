//
//  StellarMocks.swift
//  Blockchain
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import stellarsdk
import PlatformKit
import StellarKit

class StellarTradeLimitsMock: StellarTradeLimitsAPI {
    typealias AccountID = String

    func maxSpendableAmount(for accountId: AccountID) -> Single<CryptoValue> {
        return Single.just(CryptoValue.lumensZero)
    }

    func minRequiredRemainingAmount(for accountId: AccountID) -> Single<CryptoValue> {
        return Single.just(CryptoValue.lumensZero)
    }

    func isSpendable(amount: CryptoValue, for accountId: AccountID) -> Single<Bool> {
        return Single.just(true)
    }
    
    func validateCryptoAmount(amount: Crypto) -> Single<TransactionValidationResult> {
        return Single.just(.ok)
    }
}

class StellarLedgerMock: StellarLedgerAPI {
    var fallbackBaseReserve: Decimal = 0
    
    var fallbackBaseFee: Decimal = 0
    
    var current: Observable<StellarLedger> = Observable.empty()

    var currentLedger: StellarLedger?
}

class StellarTransactionMock: StellarTransactionAPI {
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountID = String

    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Completable {
        return Completable.empty()
    }

    func get(transaction transactionHash: String, completion: @escaping ((Result<StellarTransactionResponse, Error>) -> Void)) {
        completion(.failure(NSError()))
    }
}

class StellarAccountMock: StellarAccountAPI {
    typealias AccountID = String
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountDetailsCompletion = ((Result<StellarAccount, Error>) -> Void)

    var currentAccount: StellarAccount?

    var balance: Single<CryptoValue> {
        return Single.error(NSError())
    }
    var balanceObservable: Observable<CryptoValue> {
        return Observable.error(NSError())
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    func currentStellarAccountAsSingle(fromCache: Bool) -> Single<StellarAccount?> {
        return .just(nil)
    }
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        return Maybe.empty()
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        return Single.error(NSError())
    }

    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        return Maybe.empty()
    }

    func clear() {

    }

    func fundAccount(_ accountID: AccountID, amount: Decimal, sourceKeyPair: StellarKeyPair) -> Completable {
        return Completable.empty()
    }

    func prefetch() {

    }

    func validate(accountID: AccountID) -> Single<Bool> {
        return Single.just(false)
    }
    
    func isExchangeAddress(_ address: AccountID) -> Single<Bool> {
        return Single.just(false)
    }
}
