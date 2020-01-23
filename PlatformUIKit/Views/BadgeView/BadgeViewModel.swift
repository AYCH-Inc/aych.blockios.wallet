//
//  BadgeViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public struct BadgeViewModel {
    
    // MARK: - Types
    
    public struct Theme {
        public let backgroundColor: UIColor
        public let contentColor: UIColor
        public let text: String
        
        public init(backgroundColor: UIColor,
                    contentColor: UIColor,
                    text: String) {
            self.backgroundColor = backgroundColor
            self.contentColor = contentColor
            self.text = text
        }
    }
    
    // MARK: - Properties
    
    /// The theme of the view
    public var theme: Theme {
        set {
            backgroundColorRelay.accept(newValue.backgroundColor)
            contentColorRelay.accept(newValue.contentColor)
            textRelay.accept(newValue.text)
        }
        get {
            return Theme(backgroundColor: backgroundColorRelay.value,
                         contentColor: contentColorRelay.value,
                         text: textRelay.value)
        }
    }
    
    /// Accessibility for the badge view
    public let accessibility: Accessibility
    
    /// Corner radius
    public let cornerRadius: CGFloat
    
    /// The font of the label
    public let font: UIFont
    
    /// The background color relay
    public let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The background color of the badge
    public var backgroundColor: Driver<UIColor> {
        return backgroundColorRelay.asDriver()
    }
    
    /// The content color relay
    public let contentColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The content color of the title
    public var contentColor: Driver<UIColor> {
        return contentColorRelay.asDriver()
    }
    
    /// The text relay
    public let textRelay = BehaviorRelay<String>(value: "")
    
    /// Text to be displayed on the badge
    public var text: Driver<String> {
        return textRelay.asDriver()
    }
    
    /// - parameter cornerRadius: corner radius of the component
    /// - parameter accessibility: accessibility for the view
    public init(font: UIFont = .mainMedium(12), cornerRadius: CGFloat = 4, accessibility: Accessibility) {
        self.font = font
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }
}

extension BadgeViewModel {
    
    /// Returns a destructive badge with text
    public static func destructive(
        with text: String,
        accessibilityId: String = Accessibility.Identifier.General.destructiveBadgeView
        ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            accessibility: .init(id: .value(accessibilityId))
        )
        viewModel.theme = Theme(
            backgroundColor: .destructiveBackground,
            contentColor: .destructiveButton,
            text: text
        )
        return viewModel
    }
    
    /// Returns a affirmative badge with text
    public static func affirmative(
        with text: String,
        accessibilityId: String = Accessibility.Identifier.General.affirmativeBadgeView
        ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            accessibility: .init(id: .value(accessibilityId))
        )
        viewModel.theme = Theme(
            backgroundColor: .affirmativeBackground,
            contentColor: .affirmativeBadgeText,
            text: text
        )
        return viewModel
    }
    
    /// Returns a destructive button with text only
    public static func `default`(
        with text: String,
        accessibilityId: String = Accessibility.Identifier.General.defaultBadgeView
        ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            accessibility: .init(id: .value(accessibilityId))
        )
        viewModel.theme = Theme(
            backgroundColor: .defaultBadgeBackground,
            contentColor: .defaultBadge,
            text: text
        )
        return viewModel
    }
}

