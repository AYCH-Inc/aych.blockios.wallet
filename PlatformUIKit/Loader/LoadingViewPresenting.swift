//
//  LoadingViewPresenting.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 11/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Loading view presenting abstraction
public protocol LoadingViewPresenting {
    
    /// In case `isEnabled` is `false`, the loader must not show
    var isEnabled: Bool { get set }
    
    /// Is currently visible
    var isVisible: Bool { get }
    
    /// Hides the loader
    func hide()
    
    /// Shows the loader with using circular style & custom text
    func showCircular(in superview: UIView?, with text: String?)
    
    /// Shows the loader with using circular style & custom text
    func showCircular(with text: String?)
    
    /// Shows the legacy loader using a custom message
    func show(in superview: UIView?, with text: String?)
    
    /// Shows the legacy loader using a custom message
    func show(with text: String?)
}
