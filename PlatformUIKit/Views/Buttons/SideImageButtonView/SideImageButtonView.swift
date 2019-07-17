//
//  SideImageButtonView.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// A button with image to its leading side and text to its right: | 🖼️ 🔤 |
public class SideImageButtonView: UIView {
    
    // MARK: - UI Properties
    
    @IBOutlet private var button: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
    
    // Constraints for scenario with title only, and no image
    @IBOutlet private var labelToImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var labelToSuperviewLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    
    public var viewModel: SideImageButtonViewModel! {
        didSet {
            
            // Set corner radius
            layer.cornerRadius = viewModel.cornerRadius
            
            // Set accessibility
            accessibility = viewModel.accessibility
            
            // bind background color
            viewModel.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)
            
            // bind label color
            viewModel.contentColor
                .drive(label.rx.textColor)
                .disposed(by: disposeBag)
            
            // Bind label text color
            viewModel.text
                .drive(label.rx.text)
                .disposed(by: disposeBag)
            
            // Bind image view tint color
            viewModel.contentColor
                .drive(imageView.rx.tintColor)
                .disposed(by: disposeBag)
            
            // Bind image view's image
            viewModel.image
                .drive(imageView.rx.image)
                .disposed(by: disposeBag)

            // Bind view model enabled indication to button
            viewModel.isEnabled
                .drive(button.rx.isEnabled)
                .disposed(by: disposeBag)
            
            viewModel.alpha
                .drive(rx.alpha)
                .disposed(by: disposeBag)
            
            // bind contains image
            viewModel.containsImage
                .bind { [weak self] containsImage in
                    guard let self = self else { return }
                    if containsImage {
                        self.label.textAlignment = .natural
                        self.labelToImageViewLeadingConstraint.priority = .defaultHigh
                        self.labelToSuperviewLeadingConstraint.priority = .defaultLow
                    } else {
                        self.label.textAlignment = .center
                        self.labelToImageViewLeadingConstraint.priority = .defaultLow
                        self.labelToSuperviewLeadingConstraint.priority = .defaultHigh
                    }
                    self.layoutIfNeeded()
                }
                .disposed(by: disposeBag)
            
            // Bind button taps
            button.rx.tap
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)
        }
    }
    
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
        fromNib()
        clipsToBounds = true
    }
    
    // MARK: - User Interactions
    
    @IBAction private func touchUp() {
        alpha = 1
    }
    
    @IBAction private func touchDown() {
        alpha = 0.85
    }
}
