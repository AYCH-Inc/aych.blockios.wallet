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

class StellarAccountService: StellarAccountAPI {

    typealias StellarTransaction = stellarsdk.Transaction

    fileprivate let configuration: StellarConfiguration
    fileprivate let ledgerService: StellarLedgerAPI
    fileprivate let repository: WalletXlmAccountRepository
    fileprivate lazy var service: AccountService = {
       configuration.sdk.accounts
    }()

    init(
        configuration: StellarConfiguration = .production,
        ledgerService: StellarLedgerAPI,
        repository: WalletXlmAccountRepository
    ) {
        self.configuration = configuration
        self.ledgerService = ledgerService
        self.repository = repository
    }
    
    var currentAccount: StellarAccount? {
        return privateAccount.value
    }
    fileprivate var privateAccount = BehaviorRelay<StellarAccount?>(value: nil)
    
    // MARK: Private Functions
    
    fileprivate func defaultXLMAccount() -> WalletXlmAccount? {
        return repository.defaultAccount
    }
    
    // MARK: Public Functions
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        if let cached = privateAccount.value, fromCache == true {
            return Maybe.just(cached)
        }
        guard let XLMAccount = defaultXLMAccount() else {
            return Maybe.error(StellarServiceError.noXLMAccount)
        }
        let accountID = XLMAccount.publicKey
        return accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccount.accept(account)
        })
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        return Single<AccountResponse>.create { [weak self] event -> Disposable in
            self?.service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
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
    
    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        return accountResponse(for: accountID).map { details -> StellarAccount in
            return details.toStellarAccount()
        }.asMaybe()
    }
    
    func fundAccount(
        _ accountID: AccountID,
        amount: Decimal,
        sourceKeyPair: StellarKeyPair
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
                guard amount >= baseReserveInXlm * 2 else {
                    return Completable.error(StellarServiceError.insufficientFundsForNewAccount)
                }
                return strongSelf.accountResponse(for: sourceKeyPair.accountId)
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
        sourceKeyPair: StellarKeyPair
    ) -> Completable {
        return Completable.create(subscribe: { [weak self] event -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }

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
                try transaction.sign(keyPair: source, network: strongSelf.configuration.network)

                // Submit the transaction
                try strongSelf.configuration.sdk.transactions
                    .submitTransaction(transaction: transaction, response: { response -> (Void) in
                        switch response {
                        case .success(details: _):
                            event(.completed)
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
}

// MARK: - Extension

extension AccountResponse {
    func toStellarAccount() -> StellarAccount {
        let totalBalance = balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
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
            sequence: Int(sequenceNumber),
            subentryCount: Int(subentryCount)
        )
    }
}

extension HorizonRequestError {
    func toStellarServiceError() -> StellarServiceError {
        switch self {
        case .notFound:
            return .noDefaultAccount
        case .rateLimitExceeded:
            return .rateLimitExceeded
        case .internalServerError:
            return .internalError
        case .parsingResponseFailed:
            return .parsingError
        case .forbidden:
            return .forbidden
        default:
            return .unknown
        }
    }
}
