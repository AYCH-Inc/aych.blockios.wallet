//
//  InteractableTextView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

/// This component implements an interactable text view that supports links.
/// It can be used to display terms of use / provacy policy linkable text
/// without any of the `UITextView` interaction side effects.
/// Only the embedded links are interactable while other content is ignored.
public final class InteractableTextView: UITextView {
    
    // MARK: - Injected
    
    public var viewModel: InteractableTextViewModel! {
        didSet {
            let string = viewModel.inputs
                .map { input in
                    switch input {
                    case .text(string: let string):
                        return NSAttributedString(
                            string,
                            font: viewModel.textStyle.font,
                            color: viewModel.textStyle.color
                        )
                    case .url(string: let text, url: let url):
                        let link = NSMutableAttributedString(
                            text,
                            font: viewModel.linkStyle.font,
                            color: viewModel.linkStyle.color
                        )
                        link.makeHyperlink(to: url)
                        return link
                    }
                }
                .join()
            let mutableString = NSMutableAttributedString(attributedString: string)
            mutableString.add(lineSpacing: viewModel.lineSpacing)
            mutableString.add(alignment: viewModel.alignment)
            linkTextAttributes = [.foregroundColor: viewModel.linkStyle.color]
            isEditable = false
            attributedText = mutableString
            dataDetectorTypes = .link
        }
    }
    
    // MARK: - Accessors
    
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Setup
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }

    /// Setups the height according to the width
    public func setupHeight() {
        guard let attributedText = attributedText else {
            return
        }
        let height = attributedText.heightForWidth(width: bounds.width)
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = height
        } else {
            heightConstraint = heightAnchor.constraint(equalToConstant: height)
            heightConstraint.isActive = true
        }
        layoutIfNeeded()
    }

    // MARK: - Behavior Modifiers
    
    /// Cannot become first responder its since content is predetermined by `viewModel`
    override public func becomeFirstResponder() -> Bool {
        return false
    }

    /// Limits user interaction to links by identifying the closest position of touch,
    /// verifying it as a link position.
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let position = closestPosition(to: point) else { return false }
        guard let range = tokenizer.rangeEnclosingPosition(
                position,
                with: .character,
                inDirection: .layout(.left)
            ) else { return false }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
    
    /// Accepts only tap gestures
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UITapGestureRecognizer
    }
}

// MARK: - UITextViewDelegate

extension InteractableTextView: UITextViewDelegate {
        
    // Makes sure only links are handled
    public func textView(_ textView: UITextView,
                         shouldInteractWith URL: URL,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        guard interaction == .invokeDefaultAction else { return false }
        let title = textView.attributedText.attributedSubstring(from: characterRange).string
        viewModel.tapRelay.accept(TitledUrl(title: title, url: URL))
        return false
    }
}
