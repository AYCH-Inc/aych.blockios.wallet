//
//  AnimatedGradientContainerView.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `AnimatedGradientContainerView` is used with `Skeleton`. When
/// you apply a spooky 💀, it'll kick off the animation. 
public class AnimatedGradientContainerView: UIView {
    fileprivate let animatedGradientView = AnimatedGradientView(frame: .zero)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUpGradientView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpGradientView()
    }
    
    fileprivate func setUpGradientView() {
        addConstrainedSubview(animatedGradientView)
    }
    
    public func apply(_ skeleton: Skeleton) {
        animatedGradientView.apply(skeleton: skeleton)
    }
    
    public func stop() {
        animatedGradientView.stop()
    }
}
