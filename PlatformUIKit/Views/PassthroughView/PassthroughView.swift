//
//  PassthroughView.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/27/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Used for views such as the `PulseContainterView` where the view should pass interaction to the views behind it.
public class PassthroughView: UIView {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }
}
