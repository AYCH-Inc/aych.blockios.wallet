//
//  AccessibilityIdentifiers.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 12/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Accessibility {
    struct Identifier {
        struct LoadingView {
            static let prefixFormat = "LoadingView."
            static let statusLabel = "\(prefixFormat)statusLabel"
            static let loadingView = "\(prefixFormat)loadingView"
        }
    }
}
