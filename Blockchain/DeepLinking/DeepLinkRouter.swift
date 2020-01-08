//
//  DeepLinkRouter.swift
//  Blockchain
//
//  Created by kevinwu on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class DeepLinkRouter {

    private let routers: [DeepLinkRouting]

    init(routers: [DeepLinkRouting] = [
        StellarAirdropRouter(),
        KYCDeepLinkRouter(),
        KYCResubmitIdentityRouter(),
        ExchangeDeepLinkRouter()
    ]) {
        self.routers = routers
    }

    @discardableResult
    func routeIfNeeded() -> Bool {
        return routers.map { $0.routeIfNeeded() }.first { $0 } ?? false
    }
}
