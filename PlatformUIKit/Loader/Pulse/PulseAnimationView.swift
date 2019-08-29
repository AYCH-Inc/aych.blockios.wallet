//
//  PulseAnimationView.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/26/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class PulseAnimationView: UIView {
    
    private static let strokeWidth: CGFloat = 3.0
    private static let animationGroupKey: String = "animationGroup"
    
    private let expandingShapeLayer: CAShapeLayer = CAShapeLayer()
    private let animationGroup: CAAnimationGroup = CAAnimationGroup()
    
    private let button: UIButton
    
    // MARK: - Setup
    
    init(diameter: CGFloat) {
        button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        button.addTarget(self, action: #selector(pulseTapped(_:)), for: .touchUpInside)
        setupSubviews()
        isAccessibilityElement = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func pulseTapped(_ sender: UIButton) {
        // TODO: We need to relay pulse interaction
        // in order to update a user defaults key that dictates whether or not
        // to show the pulse again.
    }
    
    private func applyShapeLayerAnimations() {
        guard expandingShapeLayer.animationKeys()?.contains(where: { $0 == PulseAnimationView.animationGroupKey }) != false else { return }
        expandingShapeLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
            ).cgPath
        expandingShapeLayer.frame = bounds
        expandingShapeLayer.cornerRadius = bounds.height / 2.0
        expandingShapeLayer.masksToBounds = true
        expandingShapeLayer.fillColor = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.9).cgColor
        expandingShapeLayer.borderWidth = PulseAnimationView.strokeWidth
        expandingShapeLayer.borderColor = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.7).cgColor
        
        layer.addSublayer(expandingShapeLayer)
        
        animationGroup.animations = [
            transfromAnimation(scale: 1.0),
            opacityAnimation(),
            borderWidthAnimation(),
            borderFillColorAnimation()
        ]
        
        animationGroup.duration = 1.5
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = true
        animationGroup.repeatCount = .infinity
        
        expandingShapeLayer.add(animationGroup, forKey: PulseAnimationView.animationGroupKey)
    }
    
    private func transfromAnimation(scale: Double) -> CABasicAnimation {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = 2.5
        scale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scale.isAdditive = false
        return scale
    }
    
    private func borderWidthAnimation() -> CABasicAnimation {
        let borderAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderAnimation.fromValue = PulseAnimationView.strokeWidth
        borderAnimation.toValue = 0.0
        borderAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        borderAnimation.isAdditive = false
        return borderAnimation
    }
    
    private func borderFillColorAnimation() -> CABasicAnimation {
        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.7).cgColor
        borderAnimation.toValue = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.0).cgColor
        borderAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        borderAnimation.isAdditive = false
        return borderAnimation
    }
    
    private func opacityAnimation() -> CABasicAnimation {
        let opacity = CABasicAnimation(keyPath: "fillColor")
        opacity.fromValue = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.7).cgColor
        opacity.toValue = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.0).cgColor
        opacity.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacity.isAdditive = false
        return opacity
    }
    
    private func setupSubviews() {
        addSubview(button)
        layer.cornerRadius = self.bounds.height / 2
        backgroundColor = #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1).withAlphaComponent(0.2)
    }
    
    func animate() {
        applyShapeLayerAnimations()
    }
}
