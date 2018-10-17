//
//  StellarAccountRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class StellarAccountRepository {

    typealias SaveAccountSuccessBlock = (WalletLumensAccount) -> Void
    typealias SaveAccountErrorBlock = (String) -> Void

    private let wallet: Wallet

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    func save(
        account: WalletLumensAccount,
        success: @escaping SaveAccountSuccessBlock,
        error: @escaping SaveAccountErrorBlock
    ) {
        wallet.saveXlmAccount(account.publicKey, label: account.label, sucess: {
            success(account)
        }, error: { errorMessage in
            error(errorMessage)
        })
    }

    func accounts() -> [WalletLumensAccount]? {
        guard let xlmAccountsRaw = wallet.getXlmAccounts() else {
            return nil
        }

        guard !xlmAccountsRaw.isEmpty else {
            return nil
        }

        return xlmAccountsRaw.castJsonObjects(type: WalletLumensAccount.self)
    }
}
