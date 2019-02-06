//
//  AnimatedGradientView.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class AnimatedGradientView: UIView {
    
    override public class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    func apply(skeleton: Skeleton) {
        gradientLayer.applySkeleton(skeleton)
    }
    
    func stop() {
        gradientLayer.removeAllAnimations()
    }
}
