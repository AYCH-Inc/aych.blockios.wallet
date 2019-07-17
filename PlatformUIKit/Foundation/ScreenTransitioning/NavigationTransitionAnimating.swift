//
//  NavigationTransitionAnimating.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 18/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Define animated transitioning between screens using view controller tailored animators
public protocol NavigationTransitionAnimating {
    func prepareForAppearance(for transition: ScreenTransitioningAnimator.TransitionType)
    func appearancePropertyAnimator(for transition: ScreenTransitioningAnimator.TransitionType) -> UIViewPropertyAnimator
    func disappearancePropertyAnimator(for transition: ScreenTransitioningAnimator.TransitionType) -> UIViewPropertyAnimator
}

extension NavigationTransitionAnimating where Self: UIViewController {}
