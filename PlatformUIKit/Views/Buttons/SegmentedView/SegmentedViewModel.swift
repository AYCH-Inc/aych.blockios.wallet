//
//  SegmentedViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 11/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// The view model coupled with `SegmentedViewModel`.
/// Rx driven: drives changes in the view: opacity, enable/disable, image and text can be assigned dynamically.
/// Supports accessibility.
/// - Tag: `SegmentedViewModel`
public struct SegmentedViewModel {
    
    // MARK: - Types
    
    public struct Theme {
        public let font: UIFont
        public let selectedFont: UIFont
        public let backgroundColor: UIColor?
        public let dividerColor: UIColor?
        public let contentColor: UIColor?
        public let selectedContentColor: UIColor?
        public let borderColor: UIColor
        
        public init(font: UIFont,
                    selectedFont: UIFont,
                    backgroundColor: UIColor? = nil,
                    borderColor: UIColor = .clear,
                    dividerColor: UIColor? = nil,
                    contentColor: UIColor? = nil,
                    selectedContentColor: UIColor? = nil,
                    imageName: String? = nil) {
            self.font = font
            self.selectedFont = selectedFont
            self.selectedContentColor = selectedContentColor
            self.dividerColor = dividerColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.contentColor = contentColor
        }
    }
    
    public struct Item {
        
        /// `Content` is the styling of the item. It can either have an image
        /// or a title, but not both.
        public enum Content {
            case title(String)
            case imageName(String)
        }
        
        /// The action that will be triggered when the `Item` is tapped.
        public let action: (() -> Void)?
        
        /// The content displayed on the `Item`. It can be a stringValue
        /// or an image, but not both.
        public let content: Content
        
        // MARK: - Init
        
        init(content: Content, action: (() -> Void)? = nil) {
            self.content = content
            self.action = action
        }
        
        public static func image(named image: String, action: (() -> Void)? = nil) -> Item {
            return .init(content: .imageName(image), action: action)
        }
        
        public static func text(_ text: String, action: (() -> Void)? = nil) -> Item {
            return .init(content: .title(text), action: action)
        }
    }
    
    // MARK: - Properties
    
    /// The theme of the view
    public var theme: Theme {
        set {
            selectedFontRelay.accept(newValue.selectedFont)
            normalFontRelay.accept(newValue.font)
            selectedFontColorRelay.accept(newValue.selectedContentColor)
            dividerColorRelay.accept(newValue.dividerColor)
            backgroundColorRelay.accept(newValue.backgroundColor)
            borderColorRelay.accept(newValue.borderColor)
            contentColorRelay.accept(newValue.contentColor)
        }
        get {
            return Theme(
                font: .mainMedium(14),
                selectedFont: .mainMedium(14),
                backgroundColor: backgroundColorRelay.value,
                contentColor: contentColorRelay.value
            )
        }
    }
    
    /// Accessibility for the button view
    public let accessibility: Accessibility
    
    public let isMomentary: Bool
    
    /// Corner radius
    public let cornerRadius: CGFloat
    
    /// Items for selection
    public let items: [Item]
    
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
    public let backgroundColorRelay = BehaviorRelay<UIColor?>(value: nil)
    
    /// The background color of the button
    public var backgroundColor: Driver<UIColor?> {
        return backgroundColorRelay.asDriver()
    }
    
    /// The content color relay
    public let contentColorRelay = BehaviorRelay<UIColor?>(value: nil)
    
    /// The content color of the button, that includes image's and label's
    public var contentColor: Driver<UIColor?> {
        return contentColorRelay.asDriver()
    }
    
    public var selectedFontColor: Driver<UIColor?> {
        return selectedFontColorRelay.asDriver()
    }
    
    /// The font when the segment is not selected
    public var normalFont: Driver<UIFont> {
        return normalFontRelay.asDriver()
    }
    
    /// The font when the segment is selected
    public var selectedFont: Driver<UIFont> {
        return selectedFontRelay.asDriver()
    }
    
    /// Border color relay
    public let borderColorRelay = BehaviorRelay<UIColor>(value: .clear)
    public let dividerColorRelay = BehaviorRelay<UIColor?>(value: nil)
    public let selectedFontColorRelay = BehaviorRelay<UIColor?>(value: nil)
    public let normalFontRelay = BehaviorRelay<UIFont>(value: .mainMedium(14))
    public let selectedFontRelay = BehaviorRelay<UIFont>(value: .mainMedium(14))
    
    /// The border color around the button
    public var borderColor: Driver<UIColor> {
        return borderColorRelay.asDriver()
    }
    
    /// The color of the divider between segments.
    public var dividerColor: Driver<UIColor?> {
        return dividerColorRelay.asDriver()
    }
    
    /// The text relay
    public let textRelay = BehaviorRelay<String>(value: "")
    
    /// Text to be displayed on the button
    public var text: Driver<String> {
        return textRelay.asDriver()
    }
    
    private let disposeBag = DisposeBag()
    
    /// Streams events when the component is being tapped
    public let tapRelay = PublishRelay<Int>()
    
    /// - parameter cornerRadius: corner radius of the component
    /// - parameter accessibility: accessibility for the view
    public init(isMomentary: Bool = true,
                cornerRadius: CGFloat = 4,
                accessibility: Accessibility,
                items: [Item]) {
        self.isMomentary = isMomentary
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
        self.items = items
        
        tapRelay
            .filter { $0 >= 0 }
            .map { items[$0] }
            .compactMap { $0.action }
            .bind {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
                $0()
            }
            .disposed(by: disposeBag)
    }
    
    /// Set the theme using a mild fade animation
    public func animate(theme: Theme) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundColorRelay.accept(theme.backgroundColor)
            self.borderColorRelay.accept(theme.borderColor)
            self.contentColorRelay.accept(theme.contentColor)
        }, completion: nil)
    }
}

extension SegmentedViewModel {
    
    /// Returns a primary segemented control
    public static func primary(
        items: [Item],
        background: UIColor = .primaryButton,
        cornerRadius: CGFloat = 8,
        accessibilityId: String = Accessibility.Identifier.General.primarySegmentedControl
        ) -> SegmentedViewModel {
        var viewModel = SegmentedViewModel(
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId)),
            items: items
        )
        viewModel.theme = Theme(
            font: .mainSemibold(16),
            selectedFont: .mainSemibold(16),
            backgroundColor: background,
            borderColor: .clear,
            dividerColor: .white,
            contentColor: .white
        )
        return viewModel
    }
    
    /// Returns a white segmented control
    public static func `plain`(
        items: [Item],
        background: UIColor = .white,
        cornerRadius: CGFloat = 8,
        accessibilityId: String = Accessibility.Identifier.General.primarySegmentedControl
        ) -> SegmentedViewModel {
        var viewModel = SegmentedViewModel(
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId)),
            items: items
        )
        viewModel.theme = Theme(
            font: .mainSemibold(16),
            selectedFont: .mainSemibold(16),
            backgroundColor: background,
            borderColor: .lightBorder,
            dividerColor: .lightBorder,
            contentColor: .primaryButton
        )
        return viewModel
    }
    
    public static func `default`(
        items: [Item],
        isMomentary: Bool = true,
        cornerRadius: CGFloat = 8,
        accessibilityId: String = Accessibility.Identifier.General.primarySegmentedControl
        ) -> SegmentedViewModel {
        var viewModel = SegmentedViewModel(
            isMomentary: isMomentary,
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId)),
            items: items
        )
        viewModel.theme = Theme(
            font: .mainMedium(14),
            selectedFont: .mainSemibold(14),
            backgroundColor: nil,
            contentColor: #colorLiteral(red: 0.596, green: 0.631, blue: 0.698, alpha: 1),
            selectedContentColor: .black
        )
        return viewModel
    }
    
    /// This provides a `SegmentedView` that is styled
    /// with a `UISegmentedControl` pre-iOS 13.
    public static func legacy(
        items: [Item],
        isMomentary: Bool = true,
        cornerRadius: CGFloat = 8,
        accessibilityId: String = Accessibility.Identifier.General.primarySegmentedControl
        ) -> SegmentedViewModel {
        var viewModel = SegmentedViewModel(
            isMomentary: isMomentary,
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(accessibilityId)),
            items: items
        )
        viewModel.theme = Theme(
            font: .mainMedium(14),
            selectedFont: .mainMedium(14),
            backgroundColor: nil
        )
        return viewModel
    }
}

