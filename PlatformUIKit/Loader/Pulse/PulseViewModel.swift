//
//  PulseViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct PulseViewModel {
    public let container: UIView
    public let onSelection: () -> Void
    
    public init(container: UIView, onSelection: @escaping () -> Void) {
        self.container = container
        self.onSelection = onSelection
    }
}
