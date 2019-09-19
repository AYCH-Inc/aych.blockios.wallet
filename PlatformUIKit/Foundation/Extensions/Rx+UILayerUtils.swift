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
