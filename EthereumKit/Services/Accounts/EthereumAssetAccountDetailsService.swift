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

public class EthereumAssetAccountDetailsService: AssetAccountDetailsAPI {
    public typealias AccountDetails = EthereumAssetAccountDetails
    public typealias Bridge = EthereumWalletBridgeAPI
    
    private let bridge: EthereumWalletBridgeAPI
    
    public init(with bridge: Bridge) {
        self.bridge = bridge
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
        return Single.zip(bridge.account, bridge.balance)
            .flatMap { account, balance -> Single<EthereumAssetAccountDetails> in
                return Single.just(EthereumAssetAccountDetails(
                    account: account,
                    balance: balance
                ))
            }
            .asMaybe()
    }
}
