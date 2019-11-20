//
//  Settings.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public struct Settings {
    public struct FiatCurrency: Equatable {
        public static let `default` = FiatCurrency(symbol: "$", code: "USD")
        
        public let symbol: String
        public let code: String
                
        public init(symbol: String, code: String) {
            self.symbol = symbol
            self.code = code
        }
    }
}
