//
//  ERC20AssetAccountDetailsService.swift
//  ERC20KitTests
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import EthereumKit

public class ERC20AssetAccountDetailsService<Token: ERC20Token>: AssetAccountDetailsAPI {
    public typealias AccountDetails = ERC20AssetAccountDetails
    
    public typealias Bridge = EthereumWalletBridgeAPI

    private let bridge: Bridge
    private let service: AnyERC20BalanceService<Token>
    
    public convenience init<C: ERC20AccountAPIClientAPI>(with bridge: Bridge, accountClient: C) where C.Token == Token {
        self.init(
            with: bridge,
            service: AnyERC20BalanceService<Token>(
                with: bridge,
                accountClient: accountClient
            )
        )
    }
    
    public init(with bridge: Bridge, service: AnyERC20BalanceService<Token>) {
        self.bridge = bridge
        self.service = service
    }
    
    public func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails> {
        return bridge.address
            .flatMap { [weak self] address -> Single<(String, CryptoValue)> in
                guard let self = self else { return Single.error(ERC20Error.unknown) }
                return self.service.balance(for: address)
                    .flatMap { balance -> Single<(String, CryptoValue)> in
                        return Single.just((address, balance))
                    }
            }
            .flatMap { value -> Single<AccountDetails> in
                let (address, balance) = value
                return Single.just(
                    ERC20AssetAccountDetails(
                        account: ERC20AssetAccountDetails.Account(
                            walletIndex: 0,
                            accountAddress: address,
                            name: ""
                        ),
                        balance: balance
                    )
                )
            }
            .asMaybe()
    }
}

public protocol ERC20BalanceServiceAPI {
    associatedtype Token: ERC20Token
    
    func balance(for address: String) -> Single<CryptoValue>
}

public class AnyERC20BalanceService<Token: ERC20Token>: ERC20BalanceServiceAPI {
    
    public var ethereumAddress: Single<String> {
        return bridge.address
    }
    
    public var balanceForDetaultAccount: Single<CryptoValue> {
        return ethereumAddress
            .flatMap { [weak self] address -> Single<CryptoValue> in
                guard let self = self else { return Single.error(ERC20Error.unknown) }
                return self.balance(for: address)
            }
    }
    
    private let bridge: EthereumWalletBridgeAPI
    private let accountClient: AnyERC20AccountAPIClient<Token>
    
    init<C: ERC20AccountAPIClientAPI>(with bridge: EthereumWalletBridgeAPI, accountClient: C) where C.Token == Token {
        self.bridge = bridge
        self.accountClient = AnyERC20AccountAPIClient(accountAPIClient: accountClient)
    }
    
    public func balance(for address: String) -> Single<CryptoValue> {
        return self.accountClient.fetchWalletAccount(ethereumAddress: address)
            .map { Token.cryptoValue(from: $0.balance) ?? Token.cryptoValue(from: Decimal(0)) }
    }
}
