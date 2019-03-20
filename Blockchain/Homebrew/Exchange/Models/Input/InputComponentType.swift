//
//  InputComponentType.swift
//  Blockchain
//
//  Created by AlexM on 3/13/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum FractionalInputType {
    case tenths
    case hundredths
    case `default`
}

/// `InputComponentType` is the type of entry a user can make when
/// entering a fiat or crypto-asset value in Swap.
enum InputComponentType: Equatable {
    /// A value the precedes the decimal point
    case whole
    /// A value that follows the decimal point. Use this for crypto-assets.
    /// If the user is inputting a fiat value you will need something more granular
    /// like tenths of hundredths.
    case fractional
    /// A value that is in the tenths place
    case tenths
    /// A value that is in the hundredths place
    case hundredths
    /// A value that serves as a placeholder. e.g. when a user hits the decimal point
    /// button to insert a fractional value, sometimes a semi-opaque `0` is shown in
    /// addition to the delimiter. Usually this is removed from the model once the user
    /// enters a `fractional`, `tenths`, or `hundredths` value.
    case delimiter
}
