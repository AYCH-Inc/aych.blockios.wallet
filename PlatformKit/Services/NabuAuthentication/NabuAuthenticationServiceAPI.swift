//
//  NabuAuthenticationServiceAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

// TODO: Create a service and client out of this - separate wallet update from the
public protocol NabuAuthenticationServiceAPI: class {
    func getSessionToken(requestNewToken: Bool) -> Single<NabuSessionTokenResponse>
    func getSessionToken() -> Single<NabuSessionTokenResponse>
    func updateWalletInfo() -> Completable
}
