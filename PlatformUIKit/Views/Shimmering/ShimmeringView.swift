//
//  ShimmeringView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 01/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public final class ShimmeringView: UIView {

    final class AnimatingView: UIView, ShimmeringViewing {}

    private weak var anchorView: UIView!
    
    private let light: UIColor
    private let dark: UIColor

    private lazy var backgroundView: UIView = {
        let view = UIView(frame: bounds)
        view.backgroundColor = light
        addSubview(view)
        return view
    }()

    private lazy var animatingView: AnimatingView = {
        let view = AnimatingView(frame: bounds)
        addSubview(view)
        return view
    }()
    
    public var isShimmering: Bool {
        return animatingView.isShimmering
    }
    
    public init(in superview: UIView,
                anchorView: UIView,
                size: CGSize,
                light: UIColor = .lightShimmering,
                dark: UIColor = .darkShimmering) {
        self.anchorView = anchorView
        self.light = light
        self.dark = dark
        super.init(frame: .zero)
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: anchorView.leadingAnchor),
            topAnchor.constraint(equalTo: anchorView.topAnchor),
            heightAnchor.constraint(equalTo: anchorView.heightAnchor),
            widthAnchor.constraint(equalToConstant: size.width)
        ])
        
        let height = heightAnchor.constraint(equalToConstant: size.height)
        height.isActive = true
        
        backgroundView.fillSuperview()
        animatingView.fillSuperview()
        layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#function) is not implemented")
    }

    public func start() {
        animatingView.startShimmering(dark: dark, light: light)
    }
    
    public func stop() {
        animatingView.stopShimmering()
    }
}

