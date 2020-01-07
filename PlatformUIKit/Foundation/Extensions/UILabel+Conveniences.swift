//
//  UILabel+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct LabelContent: Equatable {
    let text: String
    let font: UIFont
    let color: UIColor
    let accessibility: Accessibility
    
    public init(text: String = "",
                font: UIFont = .systemFont(ofSize: 12),
                color: UIColor = .clear,
                accessibility: Accessibility = .none) {
        self.text = text
        self.font = font
        self.color = color
        self.accessibility = accessibility
    }
    
    public static func == (lhs: LabelContent, rhs: LabelContent) -> Bool {
        return lhs.text == rhs.text
    }
    
    public func isEmpty() -> Bool {
        return text == ""
    }
}

extension UILabel {
    public var content: LabelContent {
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            accessibility = newValue.accessibility
        }
        get {
            return LabelContent(
                text: text ?? "",
                font: font,
                color: textColor,
                accessibility: accessibility
            )
        }
    }
}

extension Reactive where Base: UILabel {
    public var content: Binder<LabelContent> {
        return Binder(base) { label, content in
            label.content = content
        }
    }
}
