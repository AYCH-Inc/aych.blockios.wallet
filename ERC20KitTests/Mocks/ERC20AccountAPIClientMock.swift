//
//  ERC20AccountAPIClientMock.swift
//  ERC20KitTests
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import EthereumKit
@testable import ERC20Kit

class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {
    static let a = ERC20AccountResponse<PaxToken>(
        accountHash: "",
        tokenHash: "",
        balance: "1.0",
        totalSent: "",
        totalReceived: "",
        decimals: 0,
        transferCount: "",
        transfers: [],
        page: "",
        size: 0
    )
    
    var fetchWalletAccountResponse: Single<ERC20AccountResponse<PaxToken>> =
        Single<ERC20AccountResponse<PaxToken>>.just(a)
    func fetchWalletAccount(ethereumAddress: String) -> Single<ERC20AccountResponse<PaxToken>> {
        return fetchWalletAccountResponse
    }
}
