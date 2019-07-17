//
//  LoadingCircleView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 11/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class LoadingCircleView: UIView {

    // MARK: - Properties
    
    /// The width of the stroke line
    let strokeWidth: CGFloat = 8
    
    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    // MARK: - Setup
    
    init(diameter: CGFloat, strokeColor: UIColor) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = strokeWidth
        layer.lineCap = .round
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)).cgPath
        isAccessibilityElement = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
