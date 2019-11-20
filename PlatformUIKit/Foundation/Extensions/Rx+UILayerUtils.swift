//
//  Rx+UILayerUtils.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 27/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

extension Reactive where Base: CALayer {
    public var borderColor: Binder<UIColor> {
        return Binder(base) { layer, color in
            layer.borderColor = color.cgColor
        }
    }
}

extension Reactive where Base: CAShapeLayer {
    public var path: Binder<UIBezierPath?> {
        return Binder(base) { layer, path in
            layer.path = path?.cgPath
        }
    }
    
    public var strokeColor: Binder<UIColor?> {
        return Binder(base) { layer, color in
            layer.strokeColor = color?.cgColor
        }
    }
    
    public var fillColor: Binder<UIColor?> {
        return Binder(base) { layer, color in
            layer.fillColor = color?.cgColor
        }
    }
    
    public var lineWidth: Binder<CGFloat> {
        return Binder(base) { layer, lineWidth in
            layer.lineWidth = lineWidth
        }
    }
}
