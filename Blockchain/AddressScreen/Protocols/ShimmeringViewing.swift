//
//  ShimmeringViewing.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

enum ShimmerDirection {
    case leftToRight
    case rightToLeft
}

/// Provides shimmering trait to the inheriting view
protocol ShimmeringViewing: class {
    
    /// The direction of the shimmer
    var shimmerDirection: ShimmerDirection { get }
}
extension ShimmeringViewing where Self: UIView {
    
    /// Starts the shimmerring of the view's content
    func startShimmering() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.white.cgColor,
                                UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.transform = CATransform3DMakeRotation(0.25 * .pi, 0, 0, 1)
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        switch shimmerDirection {
        case .leftToRight:
            animation.fromValue = -bounds.width
            animation.toValue = bounds.width
        case .rightToLeft:
            animation.fromValue = bounds.width
            animation.toValue = -bounds.width
        }
        animation.duration = 3
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmering.x")
        layer.mask = gradientLayer
        
        layoutShimmeringFrameIfNeeded()
    }
    
    /// Stops the shimerring effect
    func stopShimmering() {
        layer.mask = nil
    }
    
    /// Should be called directly from `layoutSubviews`.
    func layoutShimmeringFrameIfNeeded() {
        layer.mask?.frame = bounds
    }
}

