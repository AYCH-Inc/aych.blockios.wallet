//
//  ButtonViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// The view model coupled with `ButtonView`.
/// 1. Rx driven: drives changes in the view: opacity, enable/disable, image and text can be assigned dynamically.
/// 2. Responds to touch down by reducing opacity.
/// 3. Allows to place an image to the title side.
/// 4. Supports accessibility.
/// - Tag: `ButtonViewModel`
public struct ButtonViewModel {
    
    // MARK: - Types
    
    public struct Theme {
        public let backgroundColor: UIColor
        public let borderColor: UIColor
        public let contentColor: UIColor
        public let imageName: String?
        public let text: String
        
        public init(backgroundColor: UIColor,
                    borderColor: UIColor = .clear,
                    contentColor: UIColor,
                    imageName: String? = nil,
                    text: String) {
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.contentColor = contentColor
            self.imageName = imageName
            self.text = text
        }
    }
    
    // MARK: - Properties
    
    /// The theme of the view
    public var theme: Theme {
        set {
            backgroundColorRelay.accept(newValue.backgroundColor)
            borderColorRelay.accept(newValue.borderColor)
            contentColorRelay.accept(newValue.contentColor)
            textRelay.accept(newValue.text)
            imageName.accept(newValue.imageName)
        }
        get {
            return Theme(backgroundColor: backgroundColorRelay.value,
                         contentColor: contentColorRelay.value,
                         imageName: imageName.value,
                         text: textRelay.value)
        }
    }
    
    /// Accessibility for the button view
    public let accessibility: Accessibility
    
    /// Corner radius
    public let cornerRadius: CGFloat
    
    /// The font of the label
    public let font: UIFont
    
    /// Observe the button enabled state
    public let isEnabledRelay = BehaviorRelay<Bool>(value: true)
    
    /// Is the button enabled
    public var isEnabled: Driver<Bool> {
        return isEnabledRelay.asDriver()
    }
    
    /// Retruns the opacity of the view
    public var alpha: Driver<CGFloat> {
        return isEnabled.asDriver().map { CGFloat($0 ? 1 : 0.65) }
    }
    
    /// The background color relay
    public let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The background color of the button
    public var backgroundColor: Driver<UIColor> {
        return backgroundColorRelay.asDriver()
    }
    
    /// The content color relay
    public let contentColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The content color of the button, that includes image's and label's
    public var contentColor: Driver<UIColor> {
        return contentColorRelay.asDriver()
    }
    
    /// Border color relay
    public let borderColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The border color around the button
    public var borderColor: Driver<UIColor> {
        return borderColorRelay.asDriver()
    }
    
    /// The text relay
    public let textRelay = BehaviorRelay<String>(value: "")
    
    /// Text to be displayed on the button
    public var text: Driver<String> {
        return textRelay.asDriver()
    }
    
    /// Name for the image
    public let imageName = BehaviorRelay<String?>(value: nil)
    
    /// Streams events when the component is being tapped
    public let tapRelay = PublishRelay<Void>()
    
    /// The image corresponding to `imageName`, rendered as template
    public var image: Driver<UIImage?> {
        return imageName.asDriver()
            .map { name in
                if let name = name {
                    return UIImage(named: name)!.withRenderingMode(.alwaysTemplate)
                }
                return nil
        }
    }
    
    /// Streams `true` if the view model contains an image
    public var containsImage: Observable<Bool> {
        return imageName.asObservable()
            .map { $0 != nil }
    }
    
    /// - parameter cornerRadius: corner radius of the component
    /// - parameter accessibility: accessibility for the view
    public init(font: UIFont = .mainSemibold(16), cornerRadius: CGFloat = 8, accessibility: Accessibility) {
        self.font = font
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }
    
    /// Set the theme using a mild fade animation
    public func animate(theme: Theme) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundColorRelay.accept(theme.backgroundColor)
            self.borderColorRelay.accept(theme.borderColor)
            self.contentColorRelay.accept(theme.contentColor)
        }, completion: nil)
        textRelay.accept(theme.text)
        imageName.accept(theme.imageName)
    }
}

extension ButtonViewModel {
    
    /// Returns a primary button with text only
    public static func primary(
        with text: String,
        background: UIColor = .primaryButton,
        cornerRadius: CGFloat = 4,
        accessibilityId: String = Accessibility.Identifier.General.mainCTAButton
        ) -> ButtonViewModel {
        var viewModel = ButtonViewModel(
            font: .mainSemibold(16),
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId))
        )
        viewModel.theme = Theme(
            backgroundColor: background,
            contentColor: .white,
            text: text
        )
        return viewModel
    }
    
    /// Returns a secondary button with text only
    public static func secondary(
        with text: String,
        cornerRadius: CGFloat = 4,
        accessibilityId: String = Accessibility.Identifier.General.secondaryCTAButton
        ) -> ButtonViewModel {
        var viewModel = ButtonViewModel(
            font: .mainSemibold(16),
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId))
        )
        viewModel.theme = Theme(
            backgroundColor: .white,
            borderColor: .mediumBorder,
            contentColor: .primaryButton,
            text: text
        )
        return viewModel
    }
    
    /// Returns a destructive button with text only
    public static func destructive(
        with text: String,
        cornerRadius: CGFloat = 4,
        accessibilityId: String = Accessibility.Identifier.General.destructiveCTAButton
        ) -> ButtonViewModel {
        var viewModel = ButtonViewModel(
            font: .mainSemibold(16),
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId))
        )
        viewModel.theme = Theme(
            backgroundColor: .destructiveButton,
            contentColor: .white,
            text: text
        )
        return viewModel
    }
}
