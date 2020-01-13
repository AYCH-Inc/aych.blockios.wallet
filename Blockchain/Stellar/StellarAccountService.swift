//
//  StellarAccountService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift
import RxCocoa
import PlatformKit
import StellarKit

class StellarAccountService: StellarAccountAPI {

    typealias StellarTransaction = stellarsdk.Transaction

    // MARK: AccountBalanceFetching
    
    var balance: Single<CryptoValue> {
        return currentStellarAccount(fromCache: false)
            .flatMap(weak: self) { (self, account) -> Single<CryptoValue> in
                return Single.just(account.assetAccount.balance)
            }
            .catchError { (error) -> Single<CryptoValue> in
                guard error is StellarAccountError else { return Single.error(error) }
                return Single.just(.zero(assetType: .stellar))
            }
    }
    
    var balanceObservable: Observable<CryptoValue> {
        return balanceRelay.asObservable()
    }
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    private var disposable: Disposable?
    
    private var service: Single<AccountService> {
        return sdk.map { $0.accounts }
    }

    private var sdk: Single<stellarsdk.StellarSDK> {
        return configuration.map { $0.sdk }
    }
    
    private var configuration: Single<StellarConfiguration> {
        return configurationService.configuration
    }
    
    private let configurationService: StellarConfigurationAPI
    private let ledgerService: StellarLedgerAPI
    private let repository: StellarWalletAccountRepositoryAPI
    private let walletOptionsAPI: WalletService

    init(
        configurationService: StellarConfigurationAPI,
        ledgerService: StellarLedgerAPI,
        repository: StellarWalletAccountRepositoryAPI,
        walletService: WalletService = WalletService.shared
    ) {
        self.configurationService = configurationService
        self.ledgerService = ledgerService
        self.repository = repository
        self.walletOptionsAPI = walletService
                
        balanceFetchTriggerRelay
            .flatMapLatest(weak: self) { (self, _) in
                return self.balance.asObservable()
            }
            .catchErrorJustReturn(.lumensZero)
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
    
    var currentAccount: StellarAccount? {
        return privateAccount.value
    }
    
    fileprivate var privateAccount = BehaviorRelay<StellarAccount?>(value: nil)
    
    // MARK: Private Functions
    
    fileprivate func defaultXLMAccount() -> StellarWalletAccount? {
        return repository.defaultAccount
    }
    
    // MARK: Public Functions
    
    func clear() {
        privateAccount = BehaviorRelay<StellarAccount?>(value: nil)
    }

    func prefetch() {
        disposable = currentStellarAccount(fromCache: true).subscribe()
    }
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        if let cached = privateAccount.value, fromCache == true {
            return Maybe.just(cached)
        }
        guard let XLMAccount = defaultXLMAccount() else {
            return Maybe.error(StellarAccountError.noXLMAccount)
        }
        let accountID = XLMAccount.publicKey
        return accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccount.accept(account)
        })
    }
    
    func currentStellarAccountAsSingle(fromCache: Bool) -> Single<StellarAccount?> {
        return currentStellarAccount(fromCache: fromCache)
            .asObservable()
            .materialize()
            /// Map `completed` event into `.next(nil)` in order to convert later to `Single`.
            .map { event -> Event<StellarAccount?> in
                switch event {
                case .next(let account):
                    return .next(account)
                case .error(let error):
                    return .error(error)
                case .completed:
                    return .next(nil)
                }
            }
            .dematerialize()
            /// Only take the first - make sure that success will
            /// be streamed right after the first element.
            .take(1)
            .asSingle()
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        return service.flatMap(weak: self) { (self, service) -> Single<AccountResponse> in
            return Single<AccountResponse>.create { event -> Disposable in
                service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
                    switch response {
                    case .success(details: let details):
                        event(.success(details))
                    case .failure(error: let error):
                        event(.error(error.toStellarServiceError()))
                    }
                })
                return Disposables.create()
            }
        }
    }
    
    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        return accountResponse(for: accountID).map { details -> StellarAccount in
            return details.toStellarAccount()
        }.catchError { error in
            // If the network call to Horizon fails due to there not being a default account (i.e. account is not yet
            // funded), catch that error and return a StellarAccount with 0 balance
            if let stellarError = error as? StellarAccountError, stellarError == .noDefaultAccount {
                return Single.just(StellarAccount.unfundedAccount(accountId: accountID))
            }
            throw error
        }.asMaybe()
    }
    
    func fundAccount(
        _ accountID: AccountID,
        amount: Decimal,
        sourceKeyPair: StellarKit.StellarKeyPair
    ) -> Completable {
        return ledgerService.current.take(1)
            .asSingle()
            .flatMapCompletable { [weak self] ledger -> Completable in
                guard let strongSelf = self else {
                    return Completable.empty()
                }
                guard let baseReserveInXlm = ledger.baseReserveInXlm else {
                    return Completable.empty()
                }
                guard let amountCrypto = CryptoValue.lumensFromMajor(string: (amount as NSDecimalNumber).description(withLocale: Locale.current) ) else {
                    return Completable.empty()
                }
                guard amountCrypto.amount >= baseReserveInXlm.amount * 2 else {
                    return Completable.error(StellarFundsError.insufficientFundsForNewAccount)
                }
                return strongSelf.accountResponse(for: sourceKeyPair.accountID)
                    .flatMapCompletable { [weak self] sourceAccountResponse -> Completable in
                        guard let strongSelf = self else {
                            return Completable.never()
                        }
                        return strongSelf.fundAccountCompletable(
                            accountID,
                            amount: amount,
                            sourceAccountResponse: sourceAccountResponse,
                            sourceKeyPair: sourceKeyPair
                        )
                    }
            }
    }

    private func fundAccountCompletable(
        _ accountID: AccountID,
        amount: Decimal,
        sourceAccountResponse: AccountResponse,
        sourceKeyPair: StellarKit.StellarKeyPair
    ) -> Completable {
        return configuration.flatMap(weak: self) { (self, configuration) -> Single<Void> in
            return Single.create(subscribe: { event -> Disposable in
                do {
                    // Build operation
                    let source = try KeyPair(secretSeed: sourceKeyPair.secret)
                    let destination = try KeyPair(accountId: accountID)
                    let createAccount = CreateAccountOperation(
                        sourceAccount: nil,
                        destination: destination,
                        startBalance: amount
                    )

                    // Build the transaction
                    let transaction = try StellarTransaction(
                        sourceAccount: sourceAccountResponse,
                        operations: [createAccount],
                        memo: Memo.none,
                        timeBounds: nil
                    )

                    // Sign the transaction
                    try transaction.sign(keyPair: source, network: configuration.network)
    
                    // Submit the transaction
                    try configuration.sdk.transactions
                        .submitTransaction(transaction: transaction, response: { response -> (Void) in
                            switch response {
                            case .success(details: _):
                                event(.success(()))
                            case .failure(let error):
                                event(.error(error))
                            }
                        })
                } catch {
                    event(.error(error))
                }
                return Disposables.create()
            })
        }
        .asCompletable()
    }

    func validate(accountID: AccountID) -> Single<Bool> {
        guard accountID.count > 0,
            let _ = try? KeyPair(accountId: accountID) else {
            return Single.just(false)
        }
        return Single.just(true)
    }
    
    func isExchangeAddress(_ address: AccountID) -> Single<Bool> {
        return walletOptionsAPI.walletOptions.map { walletOptions in
            let result = walletOptions.xlmExchangeAddresses?.contains(where: { $0.uppercased() == address.uppercased() }) ?? false
            return result
        }
    }
}

// MARK: - Extension

extension AccountResponse {
    func toStellarAccount() -> StellarAccount {
        let totalBalanceDecimal = balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
        let totalBalance = CryptoValue.lumensFromMajor(string: (totalBalanceDecimal as NSDecimalNumber).description(withLocale: Locale.current)) ?? CryptoValue.lumensZero
        let assetAddress = AssetAddressFactory.create(
            fromAddressString: accountId,
            assetType: .stellar
        )
        let assetAccount = AssetAccount(
            index: 0,
            address: assetAddress,
            balance: totalBalance,
            name: LocalizationConstants.Stellar.defaultLabelName
        )
        return StellarAccount(
            identifier: accountId,
            assetAccount: assetAccount,
            sequence: sequenceNumber,
            subentryCount: subentryCount
        )
    }
}
