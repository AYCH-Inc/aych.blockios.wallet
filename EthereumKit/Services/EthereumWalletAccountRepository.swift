//
//  EthereumWalletAccountRepository.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

open class EthereumWalletAccountRepository: WalletAccountRepositoryAPI {

    public typealias Account = EthereumWalletAccount

    public typealias Bridge = EthereumWalletBridgeAPI

    // MARK: - Properties

    // For ETH, there is only one account which is the default account.
    public var defaultAccount: EthereumWalletAccount?

    fileprivate let bridge: Bridge

    // MARK: - Init

    public init(with bridge: Bridge) {
        self.bridge = bridge
    }

    // MARK: - Public methods

    public func accounts() -> [EthereumWalletAccount] {
        return []
    }
}
