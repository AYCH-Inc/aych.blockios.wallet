//
//  PriceInFiatResponse.swift
//  NetworkKit
//
//  Created by Jack on 18/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct PriceInFiatResponse: Codable {
    public let timestamp: Date?
    public let price: Decimal
    public let volume24h: Decimal?
}
