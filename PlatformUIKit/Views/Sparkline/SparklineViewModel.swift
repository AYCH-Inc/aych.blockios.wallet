//
//  SparklineViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/2/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model representing a `Sparkline`.
/// For more information, see [Wikipedia.](https://en.wikipedia.org/wiki/Sparkline)
public struct SparklineViewModel {
    
    /// The `y-values` represented in the line graph.
    /// Note that the `x-values` are derived from the `size` provided.
    /// It is assumed that the values are provided in order.
    let values: [Decimal]
    
    /// The size of the image returned. The line graph
    /// will fit this size.
    let size: CGSize
    
    /// The stroke color of the line.
    let color: UIColor
    
    /// The scale of the image. This is injected as `UIScreen` is not
    /// cross platform.
    let scale: CGFloat
    
    /// Dictates whether the line is curved and uses control points. Defaults
    /// to `false`.
    let smoothing: Bool
    
    /// The stroke width of the line. Defaults to 2.
    let strokeWidth: CGFloat
    
    public init(
        values: [Decimal],
        size: CGSize,
        scale: CGFloat,
        color: UIColor,
        strokeWidth: CGFloat = 2.0,
        smoothing: Bool = false
    ) {
        self.values = values
        self.size = size
        self.strokeWidth = strokeWidth
        self.scale = scale
        self.color = color
        self.smoothing = smoothing
    }
}

extension SparklineViewModel {
    
    /// The largest value in the dataset.
    var max: CGFloat {
        return CGFloat(values.max()?.doubleValue ?? 0)
    }
    
    /// The smallest value in the dataset.
    var min: CGFloat {
        return CGFloat(values.min()?.doubleValue ?? 0)
    }
    
    /// The width
    var width: CGFloat {
        return size.width + (strokeWidth / 2)
    }
    
    /// The height
    var height: CGFloat {
        return size.height + (strokeWidth / 2)
    }
    
    /// The normalized dataset. The plotted points are normalized
    /// so that despite what may be very small deltas across the values
    /// the chart shows the overall pattern and fills the size provided.
    var normalizedPoints: [CGPoint] {
        let interval = width / CGFloat(values.count - 1)
        return values.enumerated().map {
            let index = $0
            let value = CGFloat($1.doubleValue)
            let ratio = (value - min) / (max - min)
            let x = interval * CGFloat(index)
            let y = height * (1 - ratio)
            return .init(x: x, y: y)
        }
    }
}
