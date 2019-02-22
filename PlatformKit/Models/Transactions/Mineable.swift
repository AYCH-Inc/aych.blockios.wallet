//
//  Mineable.swift
//  PlatformKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol Mineable {
    var confirmations: Int { get }
    var isConfirmed: Bool { get }
}
