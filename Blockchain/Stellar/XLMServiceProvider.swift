//
//  XLMServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import StellarKit

protocol XLMDependenciesAPI {
    var accounts: StellarAccountAPI { get }
    var ledger: StellarLedgerAPI { get }
    var operation: StellarOperationsAPI { get }
    var transaction: StellarTransactionAPI { get }
    var limits: StellarTradeLimitsAPI { get }
    var repository: StellarWalletAccountRepositoryAPI { get }
    var prices: PriceServiceAPI { get }
    var walletActionEventBus: WalletActionEventBus { get }
    var feeService: StellarFeeServiceAPI { get }
}

struct StellarServices: XLMDependenciesAPI {
    var repository: StellarWalletAccountRepositoryAPI
    var accounts: StellarAccountAPI
    var ledger: StellarLedgerAPI
    var operation: StellarOperationsAPI
    var transaction: StellarTransactionAPI
    var prices: PriceServiceAPI
    var limits: StellarTradeLimitsAPI
    var walletActionEventBus: WalletActionEventBus
    var feeService: StellarFeeServiceAPI

    init(
        configurationService: StellarConfigurationAPI = StellarConfigurationService.shared,
        wallet: Wallet = WalletManager.shared.wallet,
        eventBus: WalletActionEventBus = WalletActionEventBus.shared,
        xlmFeeService: StellarFeeServiceAPI = StellarFeeService.shared
    ) {
        walletActionEventBus = eventBus
        repository = StellarWalletAccountRepository(with: wallet)
        ledger = StellarLedgerService(
            configurationService: configurationService,
            feeService: xlmFeeService
        )
        accounts = StellarAccountService(
            ledgerService: ledger,
            repository: repository
        )
        transaction = StellarTransactionService(
            configurationService: configurationService,
            accounts: accounts,
            repository: repository
        )
        operation = StellarOperationService(
            configurationService: configurationService,
            repository: repository
        )
        prices = PriceServiceClient()
        limits = StellarTradeLimitsService(ledgerService: ledger, accountsService: accounts)
        feeService = xlmFeeService
    }
}

class StellarServiceProvider: NSObject {
    
    let services: StellarServices
    
    static let shared = StellarServiceProvider.make()
    
    @objc static func sharedInstance() -> StellarServiceProvider {
        return shared
    }

    @objc class func make() -> StellarServiceProvider {
        return StellarServiceProvider(services: StellarServices())
    }
    
    private var ledger: StellarLedgerAPI {
        return services.ledger
    }
    
    private var accounts: StellarAccountAPI {
        return services.accounts
    }
    
    private let bag = DisposeBag()
    
    init(services: StellarServices) {
        self.services = services
        super.init()
        setup()
    }

    fileprivate func setup() {
        Observable.combineLatest(
                ledger.current,
                accounts.currentStellarAccount(fromCache: false).asObservable()
            )
            .subscribe()
            .disposed(by: bag)
    }
    
    @objc func tearDown() {
        services.accounts.clear()
        services.operation.clear()
        services.operation.end()
    }
}
