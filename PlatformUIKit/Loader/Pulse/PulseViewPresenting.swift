//
//  PulseViewPresenting.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/26/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `PulseAnimationView` presenting abstraction
public protocol PulseViewPresenting {
    
    /// In case `isEnabled` is `false`, the `PulseAnimationView` must not show
    var isEnabled: Bool { get set }
    
    /// Is currently visible
    var visibility: Visibility { get }
    
    /// Hides the `PulseAnimationView`
    func hide()
    
    /// Shows the `PulseAnimationView`. A `superview` is required. 
    func show(viewModel: PulseViewModel)
}
