//
//  Rx+UITextView.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/11/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

extension Reactive where Base: UITextView {
    public var attributedText: Binder<NSAttributedString> {
        return Binder(base) { textView, attributedText in
            textView.attributedText = attributedText
        }
    }
}
