//
//  EthereumAssetAccountDetailsService.swift
//  EthereumKit
//
//  Created by Jack on 19/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import BigInt

public class EthereumAssetAccountDetailsService: AssetAccountDetailsAPI {
    public typealias AccountDetails = EthereumAssetAccountDetails
    public typealias Bridge = EthereumWalletBridgeAPI
    
    private let bridge: EthereumWalletBridgeAPI
    private let client: EthereumAPIClientAPI
    
    public init(with bridge: Bridge, client: EthereumAPIClientAPI) {
        self.bridge = bridge
        self.client = client
    }
    
    public func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails> {
        #if DEBUG
            return getAccountDetailsPlatform(for: accountID)
        #else
            return getAccountDetailsLegacy(for: accountID)
        #endif
    }
    
    private func getAccountDetailsPlatform(for accountID: AccountID) -> Maybe<AccountDetails> {
        // TODO: get account natively
        return getAccountDetailsLegacy(for: accountID)
    }
    
    private func getAccountDetailsLegacy(for accountID: AccountID) -> Maybe<AccountDetails> {
        // FIXME: account id unused
        return Single.zip(bridge.account, balance)
            .flatMap { account, ethereumBalance -> Single<EthereumAssetAccountDetails> in
                return Single.just(EthereumAssetAccountDetails(
                    account: account,
                    balance: ethereumBalance
                ))
            }
            .asMaybe()
    }
    
    private var balance: Single<CryptoValue> {
        return bridge.address.flatMap(weak: self, { (self, address) -> Single<CryptoValue> in
             return self.client.fetchBalance(from: address)
        })
    }
}
