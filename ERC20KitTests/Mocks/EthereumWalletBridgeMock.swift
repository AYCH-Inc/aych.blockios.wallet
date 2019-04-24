//
//  EthereumWalletBridgeMock.swift
//  ERC20KitTests
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import EthereumKit
@testable import ERC20Kit

class EthereumWalletBridgeMock: EthereumWalletBridgeAPI {
    
    var balanceValue: Single<CryptoValue> = Single.just(CryptoValue.paxFromMajor(decimal: Decimal(1.0)))
    var balance: Single<CryptoValue> {
        return balanceValue
    }
    
    var nameValue: Single<String> = Single.just("")
    var name: Single<String> {
        return nameValue
    }
    
    var addressValue: Single<String> = Single.just("")
    var address: Single<String> {
        return addressValue
    }
    
    var transactionsValue: Single<[EthereumTransaction]> = Single.just([])
    var transactions: Single<[EthereumTransaction]> {
        return transactionsValue
    }
    
    static let assetAccount = EthereumAssetAccount(walletIndex: 0, accountAddress: "", name: "")
    var accountValue: Single<EthereumAssetAccount> = Single.just(assetAccount)
    var account: Single<EthereumAssetAccount> {
        return accountValue
    }
}
