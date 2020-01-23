//
//  BadgeView.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// A small view that typically sits in a `UITableViewCell` showing
/// a state such as verified, rejected, or a flag indicating the
/// currency you have selected in settings.
public final class BadgeView: UIView {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var containerView: UIView!
    
    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    public var viewModel: BadgeViewModel! {
        didSet {
            disposeBag = DisposeBag()
            
            // Set non-reactive properties
            layer.cornerRadius = viewModel.cornerRadius
            titleLabel.font = viewModel.font
            
            // Set accessibility
            accessibility = viewModel.accessibility
            
            // Bind background color
            viewModel.backgroundColor
                .drive(containerView.rx.backgroundColor)
                .disposed(by: disposeBag)
            
            // bind label color
            viewModel.contentColor
                .drive(titleLabel.rx.textColor)
                .disposed(by: disposeBag)
            
            // Bind label text
            viewModel.text
                .drive(titleLabel.rx.text)
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
}
