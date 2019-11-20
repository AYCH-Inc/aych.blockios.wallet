//
//  Double+Utils.swift
//  PlatformKit
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Double {
    public func string(with decimalPrecision: Int) -> String {
        return String(format: "%.\(decimalPrecision)f", self)
    }
}
