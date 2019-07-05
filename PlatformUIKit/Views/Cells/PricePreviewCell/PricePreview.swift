//
//  PricePreview.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct PricePreview: Equatable {
    public let title: String
    public let value: FiatValue
    public let logo: UIImage
    public let CTA: String
    public let action: () -> Void
}

extension PricePreview {
    public static func ==(lhs: PricePreview, rhs: PricePreview) -> Bool {
        return lhs.value == rhs.value &&
        lhs.title == rhs.title &&
        lhs.CTA == rhs.CTA
    }
}
