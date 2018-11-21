//
//  DeepLinkPayload.swift
//  Blockchain
//
//  Created by Fred Cheng on 11/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct DeepLinkPayload {
    let route: DeepLinkRoute
    let params: [String: String]
}

extension DeepLinkPayload {
    static func create(from url: URL) -> DeepLinkPayload? {
        guard let route = DeepLinkRoute.route(from: url) else { return nil }
        return DeepLinkPayload(route: route, params: extractParams(from: url))
    }

    private static func extractParams(from url: URL) -> [String: String] {
        guard let lastPathWithProperties = url.absoluteString.components(separatedBy: "/").last else {
            return [:]
        }

        let pathToParametersComponents = lastPathWithProperties.components(separatedBy: "?")

        var parameters = [String: String]()
        let parameterPairs = pathToParametersComponents.last?.components(separatedBy: "&")
        parameterPairs?.forEach { pair in
            let paramComponents = pair.components(separatedBy: "=")
            guard let key = paramComponents.first,
                let value = paramComponents.last?.removingPercentEncoding else {
                    return
            }
            parameters[key] = value
        }
        return parameters
    }
}
