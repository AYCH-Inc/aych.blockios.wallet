//
//  Rx+UIViewUtils.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

/// Extension for rx that makes `UIView` properties reactive
extension Reactive where Base: UIView {
    public var backgroundColor: Binder<UIColor> {
        return Binder(base) { view, color in
            view.backgroundColor = color
        }
    }
}

extension Reactive where Base: UILabel {
    public var textColor: Binder<UIColor> {
        return Binder(base) { label, color in
            label.textColor = color
        }
    }
}

extension Reactive where Base: UIImageView {
    public var tintColor: Binder<UIColor> {
        return Binder(base) { imageView, color in
            imageView.tintColor = color
        }
    }
}
