//
//  EthereumWalletBridgeAPI.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol EthereumWalletBridgeAPI: class {

    // MARK: - Getters

    func balance() -> CryptoValue

    func name() -> String

    func address() -> String

    func transactions() -> [EthereumTransaction]
}
