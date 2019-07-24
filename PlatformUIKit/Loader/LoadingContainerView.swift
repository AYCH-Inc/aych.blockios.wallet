//
//  LoadingContainerView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class LoadingContainerView: UIView {

    // MARK: - Properties
    
    private let max: CGRect = .init(origin: .zero, size: .init(width: 85.0, height: 85.0))
    
    private lazy var loadingBackgroundView: LoadingCircleView = {
        let circle = LoadingCircleView(
            diameter: self.frame.min(max).width,
            strokeColor: .init(white: 0.24, alpha: 1.0)
        )
        return circle
    }()
    
    private lazy var loadingView: LoadingAnimatingView = {
        let loading = LoadingAnimatingView(
            diameter: self.frame.min(max).width,
            strokeColor: .white
        )
        return loading
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Font(.branded(.montserratRegular), size: .custom(15)).result
        label.accessibility = Accessibility(id: .value(Accessibility.Identifier.LoadingView.statusLabel),
                                            traits: .value(.updatesFrequently))
        return label
    }()
    
    // MARK: - Setup
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .greyFade800
        isUserInteractionEnabled = true
        
        for view in [loadingBackgroundView, loadingView] {
            self.addSubview(view)
            view.layoutToSuperview(.center)
            view.layoutSize(to: CGSize(width: frame.min(max).width, height: frame.min(max).height))
        }
        
        addSubview(statusLabel)
        statusLabel.layoutToSuperview(.horizontal, offset: 50)
        statusLabel.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 32).isActive = true
        
        alpha = Visibility.hidden.defaultAlpha
        let scale = CGAffineTransform(scaleX: 0, y: 0)
        loadingBackgroundView.transform = scale
        loadingView.transform = scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LoadingViewProtocol

extension LoadingContainerView: LoadingViewProtocol {
    func animate(from oldState: LoadingViewPresenter.State, text: String?) {
        UIView.transition(with: statusLabel, duration: 0.25,
                          options: [.beginFromCurrentState, .curveEaseOut, .transitionCrossDissolve],
                          animations: {
                            self.statusLabel.text = text
        }, completion: nil)
        if !oldState.isAnimating {
            layoutIfNeeded()
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
            animator.addAnimations {
                self.alpha = Visibility.visible.defaultAlpha
            }
            animator.addAnimations({
                self.loadingBackgroundView.transform = .identity
                self.loadingView.transform = .identity
                self.loadingView.animate()
            }, delayFactor: 0.1)
            animator.startAnimation()
        }
    }
    
    func fadeOut() {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn)
        animator.addAnimations {
            let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.loadingBackgroundView.transform = scale
            self.loadingView.transform = scale
        }
        animator.addAnimations({
            self.alpha = Visibility.hidden.defaultAlpha
        }, delayFactor: 0.1)
        animator.addCompletion { _ in
            self.removeFromSuperview()
        }
        animator.startAnimation()
    }
}
