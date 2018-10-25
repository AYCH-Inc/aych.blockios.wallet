//
//  XLMServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol XLMDependencies {
    var accounts: StellarAccountAPI { get }
    var ledger: StellarLedgerService { get }
    var operation: StellarOperationService { get }
    var transaction: StellarTransactionAPI { get }
    var repository: WalletXlmAccountRepository { get }
}

struct XLMServices: XLMDependencies {
    var repository: WalletXlmAccountRepository
    var accounts: StellarAccountAPI
    var ledger: StellarLedgerService
    var operation: StellarOperationService
    var transaction: StellarTransactionAPI
    
    init(
        configuration: StellarConfiguration,
        wallet: Wallet = WalletManager.shared.wallet
        ) {
        repository = WalletXlmAccountRepository(wallet: wallet)
        accounts = StellarAccountService(configuration: configuration, repository: repository)
        ledger = StellarLedgerService(configuration: configuration)
        transaction = StellarTransactionService(configuration: configuration, repository: repository)
        operation = StellarOperationService(configuration: configuration, repository: repository)
    }
}

class XLMServiceProvider: NSObject {
    
    let services: XLMServices
    
    init(services: XLMServices) {
        self.services = services
        super.init()
    }
}
