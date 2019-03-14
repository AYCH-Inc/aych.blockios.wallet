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
        KYCResubmitIdentityRouter()
    ]) {
        self.routers = routers
    }

    func routeIfNeeded() {
        // TODO: Is there a better way to do this?
        routers.forEach { $0.routeIfNeeded() }
    }
}
