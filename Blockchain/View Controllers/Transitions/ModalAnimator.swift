//
//  ModalAnimator.swift
//  Blockchain
//
//  Created by AlexM on 12/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

/// `ModalAnimator` is currently only used in `Swap` for showing or hiding the `Tiers` screen.
/// If we want to use this elsewhere we may want to polish this up and add options for adding
/// spring animations. 
class ModalAnimator: NSObject {
    
    enum Operation {
        case present
        case dismiss
    }
    
    fileprivate let operation: Operation
    fileprivate let duration: TimeInterval
    fileprivate let xOrigin: CGFloat = 20
    
    init(operation: Operation, duration: TimeInterval) {
        self.operation = operation
        self.duration = duration
    }
}

extension ModalAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .dismiss:
            animatePop(transitionContext)
        case .present:
            animatePush(transitionContext)
            
        }
    }
}

extension ModalAnimator {
    fileprivate func animatePush(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        container.backgroundColor = fromViewController.view.backgroundColor
        container.addSubview(toViewController.view)
        
        let finalToFrame = fromViewController.view.frame
        var startingToFrame = fromViewController.view.frame
        
        startingToFrame.origin.y -= fromViewController.view.frame.height
        startingToFrame.origin.x = fromViewController.view.frame.origin.x
        
        toViewController.view.alpha = 0
        toViewController.view.frame = startingToFrame
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                fromViewController.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.6, animations: {
                fromViewController.view.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75, animations: {
                toViewController.view.alpha = 1
                toViewController.view.frame = finalToFrame
            })
        }) { finished in
            transitionContext.completeTransition(true)
            fromViewController.view.transform = CGAffineTransform.identity
        }
    }
    
    fileprivate func animatePop(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        container.backgroundColor = fromViewController.view.backgroundColor
        container.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        toViewController.view.frame = fromViewController.view.frame
        toViewController.view.alpha = 0
        toViewController.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                fromViewController.view.frame.origin.y -= self.xOrigin
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                fromViewController.view.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.75, animations: {
                toViewController.view.transform = .identity
                toViewController.view.alpha = 1
            })
        }) { finished in
            if finished && !transitionContext.transitionWasCancelled {
                transitionContext.completeTransition(true)
            } else {
                transitionContext.completeTransition(false)
            }
            
            fromViewController.view.transform = CGAffineTransform.identity
        }
    }
}
