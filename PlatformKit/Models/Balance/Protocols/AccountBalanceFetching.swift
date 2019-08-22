//
//  AccountBalanceFetching.swift
//  PlatformKit
//
//  Created by Daniel Huri on 12/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// This protocol defines a single responsibility requirement for an account balance fetching
public protocol AccountBalanceFetching: class {
    var fetchBalance: Single<CryptoValue> { get }
}
