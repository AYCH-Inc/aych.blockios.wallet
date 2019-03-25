//
//  EthereumWalletBridgeAPI.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol EthereumWalletBridgeAPI: class {
    var balance: Single<CryptoValue> { get }
    var name: Single<String> { get }
    var address: Single<String> { get }
    var transactions: Single<[EthereumTransaction]> { get }
    var account: Single<EthereumAssetAccount> { get }
}
