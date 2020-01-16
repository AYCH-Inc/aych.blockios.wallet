//
//  SwipeInstructionView.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class SwipeInstructionView: UIView {
    
    // MARK: - Properties
    
    private let backView = ContentView()
    private let frontView = ContentView()
    
    // MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        for view in [backView, frontView] {
            addSubview(view)
            view.fillSuperview()
        }
        accessibility = Accessibility(id: .value(AccessibilityIdentifiers.PinScreen.swipeLabel),
                                      hint: .value(LocalizationConstants.Pin.Accessibility.swipeHint))
    }
    
    func setup(text: String,
               font: UIFont,
               color: UIColor = .white) {
        backView.setup(text: text, font: font, color: color.withAlphaComponent(0.2), startShimmering: false)
        frontView.setup(text: text, font: font, color: color)
    }
}

// MARK: - Content Type

extension SwipeInstructionView {
    
    private final class ContentView: UIView, ShimmeringViewing {
        
        // MARK: - Properties
        
        private let imageView = UIImageView()
        private let label = UILabel()
        
        let shimmerDirection = ShimmerDirection.rightToLeft

        // MARK: - Setup
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            layoutShimmeringFrameIfNeeded()
        }
        
        private func setup() {
            addSubview(label)
            label.layoutToSuperview(axis: .vertical)
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            
            imageView.image = UIImage(named: "back_icon")!.withRenderingMode(.alwaysTemplate)
            addSubview(imageView)
            imageView.layoutToSuperview(axis: .vertical)
            
            let imageToLabelSpace: CGFloat = 8
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                               constant: imageToLabelSpace),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 13),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
                ])
        }
        
        func setup(text: String,
                   font: UIFont,
                   color: UIColor = .white,
                   startShimmering: Bool = true) {
            label.font = font
            label.text = text
            label.textColor = color
            imageView.tintColor = color
            layoutIfNeeded()
            if startShimmering {
                self.startShimmering(dark: .clear, light: .white)
            }
        }
    }
}
