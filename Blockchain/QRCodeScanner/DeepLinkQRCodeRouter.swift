//
//  DeepLinkQRCodeRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class DeepLinkQRCodeRouter {
    
    // MARK: - Properties
    
    private let deepLinkHandler = DeepLinkHandler()
    private let deepLinkRouter = DeepLinkRouter()
    private let supportedRoutes: [DeepLinkRoute]
    
    // MARK: - Setup
    
    /// Initilized with supported routes as we don't want the client to act on any known route
    init(supportedRoutes: [DeepLinkRoute]) {
        self.supportedRoutes = supportedRoutes
    }
    
    @discardableResult
    func routeIfNeeded(using scanResult: Result<String, QRScannerError>) -> Bool {
        switch scanResult {
        case .success(let link): // Act immediately on the received link
            return routeIfNeeded(using: link)
        case .failure:
            return false
        }
    }
    
    /// Uses the given link for routing (if needed)
    func routeIfNeeded(using link: String) -> Bool {
        guard let link = link.urlDecoded else { return false }
        deepLinkHandler.handle(deepLink: link, supportedRoutes: supportedRoutes)
        return deepLinkRouter.routeIfNeeded()
    }
}
