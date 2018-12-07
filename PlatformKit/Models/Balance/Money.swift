//
//  Money.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol Money {
    
    /// The currency code for the money (e.g. "USD", "BTC", etc.)
    var currencyCode: String { get }
    
    var isZero: Bool { get }
    var isPositive: Bool { get }
    
    /// The symbol for the money (e.g. "$", "BTC", etc.)
    var symbol: String { get }
    
    /// The maximum number of decimal places supported by the money
    var maxDecimalPlaces: Int { get }
    
    /// The maximum number of displayable decimal places.
    var maxDisplayableDecimalPlaces: Int { get }
    
    /// Converts this money to a displayable String
    ///
    /// - Parameter includeSymbol: whether or not the symbol should be included in the string
    /// - Returns: the displayable String
    func toDisplayString(includeSymbol: Bool, locale: Locale) -> String
}
