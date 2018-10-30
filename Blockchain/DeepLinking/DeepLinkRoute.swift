//
//  DeepLinkRoute.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum DeepLinkRoute: String {
    case xlmAirdop = "airdrop"
}

extension DeepLinkRoute {
    static func route(from url: URL) -> DeepLinkRoute? {
        guard let lastPathWithProperties = url.absoluteString.components(separatedBy: "/").last else {
            return nil
        }

        guard let route = lastPathWithProperties.components(separatedBy: "?").first else {
            return nil
        }

        return DeepLinkRoute(rawValue: route)
    }
}
