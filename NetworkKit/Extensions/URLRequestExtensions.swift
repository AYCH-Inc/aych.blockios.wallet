//
//  URLRequestExtensions.swift
//  PlatformKit
//
//  Created by Jack on 08/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension URLRequest {
    public init(url: URL, method: HTTPMethod) {
        self.init(url: url)
        self.httpMethod = method.rawValue
    }
}
