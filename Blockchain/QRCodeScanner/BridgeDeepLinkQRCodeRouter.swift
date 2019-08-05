//
//  BridgeDeepLinkHandler.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Legacy for old QR - should NOT be used in new components!
@objc class BridgeDeepLinkQRCodeRouter: NSObject {
    let router = DeepLinkQRCodeRouter(supportedRoutes: [.pitLinking])

    @objc func handle(deepLink: String) -> Bool {
        return router.routeIfNeeded(using: deepLink)
    }
}
