//
//  Sparkline.swift
//  PlatformUIKit
//
//  Created by AlexM on 9/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

/// For more information, see [Wikipedia.](https://en.wikipedia.org/wiki/Sparkline)
/// Per the definition, the `Sparkline` is not intended to be a visual representation
/// with (x,y) coordinates, but rather memorable and succint.
public struct Sparkline {
    
    private let viewModel: SparklineViewModel
    
    public init(viewModel: SparklineViewModel) {
        self.viewModel = viewModel
    }
    
    /// The `Sparkline` image which should be inserted into a `UIImageView`.
    public var image: UIImage? {
        UIGraphicsBeginImageContextWithOptions(viewModel.size, false, viewModel.scale)
        UIGraphicsBeginImageContext(viewModel.size)
        viewModel.color.setStroke()
        let path = makePath()
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// The path derived from the `normalizedPoints`.
    func makePath() -> UIBezierPath {
        let line = UIBezierPath()
        let points = viewModel.normalizedPoints
        
        line.move(to: points.first ?? .zero)
        line.lineCapStyle = .round
        line.lineJoinStyle = .round
        line.lineWidth = viewModel.strokeWidth
        
        if points.count == 2 {
            guard let last = points.last else { return line }
            line.addLine(to: last)
            return line
        }
        
        guard var previous = points.first else { return line }
        
        if viewModel.smoothing {
            points.forEach { point in
                let delta = point.x - previous.x
                let xOffset = previous.x + (delta / 2.0)
                let controlA = CGPoint(x: xOffset, y: previous.y)
                let controlB = CGPoint(x: xOffset, y: point.y)
                
                line.addCurve(to: point, controlPoint1: controlA, controlPoint2: controlB)
                previous = point
            }
        } else {
            points.forEach {
                line.addLine(to: $0)
            }
        }
        
        return line
    }
}
