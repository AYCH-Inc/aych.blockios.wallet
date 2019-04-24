//
//  ERC20AccountAPIClientAPI.swift
//  ERC20Kit
//
//  Created by Jack on 16/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import EthereumKit
import RxSwift

public protocol ERC20AccountAPIClientAPI {
    associatedtype Token: ERC20Token
    
    func fetchWalletAccount(ethereumAddress: String) -> Single<ERC20AccountResponse<Token>>
}

final class AnyERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {
    private let fetchAccountClosure: (String) -> Single<ERC20AccountResponse<Token>>
    
    init<C: ERC20AccountAPIClientAPI>(accountAPIClient: C) where C.Token == Token {
        self.fetchAccountClosure = accountAPIClient.fetchWalletAccount
    }
    
    func fetchWalletAccount(ethereumAddress: String) -> Single<ERC20AccountResponse<Token>> {
        return fetchAccountClosure(ethereumAddress)
    }
}
