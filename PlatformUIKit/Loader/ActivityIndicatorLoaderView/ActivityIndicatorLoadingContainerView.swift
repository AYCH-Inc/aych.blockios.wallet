//
//  ActivityIndicatorLoadingContainerView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 16/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// This view is responsible to show the app's loading screen (a remake of the old loader)
final class ActivityIndicatorLoadingContainerView: UIView {
    
    // MARK: - Properties
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var messageLabel: UILabel!
    
    // MARK: - Setup
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        messageLabel.font = Font(.branded(.montserratRegular), size: .standard(.medium(.h3))).result
        messageLabel.accessibility = Accessibility(id: .value(Accessibility.Identifier.LoadingView.statusLabel),
                                                   traits: .value(.updatesFrequently))
        containerView.layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LoadingViewProtocol

extension ActivityIndicatorLoadingContainerView: LoadingViewProtocol {
    func animate(from oldState: LoadingViewPresenter.State, text: String?) {
        UIView.transition(with: messageLabel, duration: 0.25,
                          options: [.beginFromCurrentState, .curveEaseOut, .transitionCrossDissolve],
                          animations: {
                            self.messageLabel.text = text
        }, completion: nil)
        if !oldState.isAnimating {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
                self.alpha = Visibility.visible.defaultAlpha
            }, completion: nil)
        }
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
            self.alpha = Visibility.hidden.defaultAlpha
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
