//
//  NabuAuthenticationServiceMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class NabuAuthenticationServiceMock: NabuAuthenticationServiceAPI {
    
    var getSessionTokenValue = Single<NabuSessionTokenResponse>.error(NSError())
    func getSessionToken(requestNewToken: Bool) -> Single<NabuSessionTokenResponse> {
        return getSessionTokenValue
    }
    
    func getSessionToken() -> Single<NabuSessionTokenResponse> {
        return getSessionToken(requestNewToken: false)
    }
    
    func updateWalletInfo() -> Completable {
        return Completable.empty()
    }
}
