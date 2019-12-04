//
//  UIStackView+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 5/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

extension UIStackView {
    public func addBackgroundColor(_ color: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
    }
}

extension Reactive where Base: UIStackView {
    public var alignment: Binder<UIStackView.Alignment> {
        return Binder(base) { stackView, alignment in
            stackView.alignment = alignment
        }
    }
}
