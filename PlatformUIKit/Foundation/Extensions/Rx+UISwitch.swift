//
//  Rx+UISwitch.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

extension Reactive where Base: UISwitch {
    public var thumbFillColor: Binder<UIColor?> {
        return Binder(base) { switchView, color in
            guard let color = color else { return }
            switchView.thumbTintColor = color
        }
    }
    
    public var fillColor: Binder<UIColor> {
        return Binder(base) { switchView, fillColor in
            switchView.onTintColor = fillColor
        }
    }
    
    public var isEnabled: Binder<Bool> {
        return Binder(base) { switchView, isEnabled in
            switchView.isEnabled = isEnabled
        }
    }
}
