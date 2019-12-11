//
//  TwoFAWalletClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol TwoFAWalletClientAPI: class {
    func payload(guid: String, sessionToken: String, code: String) -> Single<WalletPayload>
}
