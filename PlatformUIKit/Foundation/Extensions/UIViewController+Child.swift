//
//  UIViewController+Child.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Adds a child view controller and its view
    public func add(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    // Removes self from parent view controller. Also removes its view from the superview
    public func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
