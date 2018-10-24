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
    
    fileprivate let configuration: StellarConfiguration
    fileprivate let repository: WalletXlmAccountRepository
    fileprivate lazy var service: AccountService = {
       configuration.sdk.accounts
    }()

    init(configuration: StellarConfiguration = .production,
         repository: WalletXlmAccountRepository
        ) {
        self.configuration = configuration
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
    
    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        return Maybe<StellarAccount>.create { [weak self] event -> Disposable in
            self?.service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
                switch response {
                case .success(details: let details):
                    let totalBalance = details.balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
                    let assetAddress = AssetAddressFactory.create(
                        fromAddressString: accountID,
                        assetType: .stellar
                    )
                    let assetAccount = AssetAccount(
                        index: 0,
                        address: assetAddress,
                        balance: totalBalance,
                        name: LocalizationConstants.Stellar.defaultLabelName
                    )
                    let account = StellarAccount(
                        identifier: accountID,
                        assetAccount: assetAccount,
                        sequence: Int(details.sequenceNumber),
                        subentryCount: Int(details.subentryCount)
                    )
                    
                    event(.success(account))
                    
                case .failure(error: let error):
                    switch error {
                    case .notFound:
                        event(.error(StellarServiceError.noDefaultAccount))
                    case .rateLimitExceeded:
                        event(.error(StellarServiceError.rateLimitExceeded))
                    case .internalServerError:
                        event(.error(StellarServiceError.internalError))
                    case .parsingResponseFailed:
                        event(.error(StellarServiceError.parsingError))
                    case .forbidden:
                        event(.error(StellarServiceError.forbidden))
                    default:
                        event(.error(StellarServiceError.unknown))
                    }
                }
            })
            return Disposables.create()
        }
    }
    
    func accountDetails(
        for accountID: StellarAccountAPI.AccountID,
        completion: @escaping AccountDetailsCompletion) {
        service.getAccountDetails(accountId: accountID) { response -> Void in
            switch response {
            case .success(details: let details):
                let totalBalance = details.balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
                let assetAddress = AssetAddressFactory.create(
                    fromAddressString: accountID,
                    assetType: .stellar
                )
                let assetAccount = AssetAccount(
                    index: 0,
                    address: assetAddress,
                    balance: totalBalance,
                    name: LocalizationConstants.Stellar.defaultLabelName
                )
                let account = StellarAccount(
                    identifier: accountID,
                    assetAccount: assetAccount,
                    sequence: Int(details.sequenceNumber),
                    subentryCount: Int(details.subentryCount)
                )
                completion(.success(account))
            case .failure(error: let error):
                completion(.error(error))
            }
        }
    }
    
    func fundAccount(
        with accountID: StellarAccountAPI.AccountID,
        amount: Decimal,
        completion: @escaping StellarAccountAPI.CompletionHandler) {
        // TODO: Create and fund account
    }
}
