//
//  InteractableTextViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public struct TitledUrl {
    public let title: String
    public let url: URL
}

/// A view model for `InteractableTextView`
public struct InteractableTextViewModel {
    
    /// A style for text or lonk
    public struct Style {
        public let color: UIColor
        public let font: UIFont
        
        public init(color: UIColor, font: UIFont) {
            self.color = color
            self.font = font
        }
    }
    
    /// An input with either a url or a string.
    /// Each input is formatted according to its nature
    public enum Input {
        /// A linkable url string
        case url(string: String, url: String)
        
        /// A regular string
        case text(string: String)
    }
    
    /// Steams the url upon each tap
    public var tap: Observable<TitledUrl> {
        return tapRelay.asObservable()
    }
        
    /// An array of inputs
    let inputs: [Input]
    let textStyle: Style
    let linkStyle: Style
    let alignment: NSTextAlignment
    let lineSpacing: CGFloat

    let tapRelay = PublishRelay<TitledUrl>()
    
    public init(inputs: [Input],
                textStyle: Style,
                linkStyle: Style,
                lineSpacing: CGFloat = 0,
                alignment: NSTextAlignment = .natural) {
        self.inputs = inputs
        self.textStyle = textStyle
        self.linkStyle = linkStyle
        self.lineSpacing = lineSpacing
        self.alignment = alignment
    }
}
