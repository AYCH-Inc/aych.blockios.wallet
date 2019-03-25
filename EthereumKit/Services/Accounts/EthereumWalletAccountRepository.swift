//
//  EthereumWalletAccountRepository.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

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
    
    public func initializeMetadataMaybe() -> Maybe<Account> {
        return loadDefaultAccount()
    }

    public func accounts() -> [Account] {
        guard let defaultAccount = defaultAccount else {
            return []
        }
        return [ defaultAccount ]
    }
    
    // MARK: - Private methods
    
    private func loadDefaultAccount() -> Maybe<Account> {
        return Single.zip(bridge.address, bridge.name)
            .asObservable()
            .flatMap { address, name -> Maybe<EthereumWalletAccount> in
                let account = EthereumWalletAccount(
                    index: 0,
                    publicKey: address,
                    label: name,
                    archived: false // TODO: This should be checked/enforced somehow
                )
                return Maybe.just(account)
            }
            .do(onNext: { account in
                self.defaultAccount = account
            })
            .asMaybe()
    }
}
