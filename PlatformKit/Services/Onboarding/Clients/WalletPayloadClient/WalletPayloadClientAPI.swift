//
//  WalletPayloadClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol WalletPayloadClientAPI: class {
    func payload(guid: String,
                 identifier: WalletPayloadClient.Identifier) -> Single<WalletPayloadClient.ClientResponse>
}
