//
//  UnretainedContentBox.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A box the wraps any content weakly. Handy for enums with an associated value that we do not wish to retain
public struct UnretainedContentBox<T: AnyObject> {
    public weak var value: T?
    public init(_ value: T?) {
        self.value = value
    }
}
