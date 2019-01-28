//
//  UIView+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension UIView {
    public func constrain(to view: UIView) {
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    public func addConstrainedSubview(_ subview: UIView) {
        subview.frame = bounds
        addSubview(subview)
        subview.constrain(to: self)
    }
}
