//
//  SwitchView.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// A container for a `UISwitch`. Mainly this is for making
/// `UISwitch` a bit more Rx friendly so that you can apply a
/// `viewModel`
public class SwitchView: UIView {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var switchView: UISwitch!
    
    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    public var viewModel: SwitchViewModel! {
        didSet {
            disposeBag = DisposeBag()
            
            // Set accessibility
            accessibility = viewModel.accessibility
            
            // Bind fill color
            viewModel.fillColor
                .drive(switchView.rx.fillColor)
                .disposed(by: disposeBag)
            
            // Bind thumb tint color
            viewModel.thumbTintColor
                .drive(switchView.rx.thumbFillColor)
                .disposed(by: disposeBag)
            
            // Bind enabled property
            viewModel.isEnabled
                .map { return $0 }
                .drive(switchView.rx.isEnabled)
                .disposed(by: disposeBag)
            
            switchView.rx.isOn
                .changed
                .distinctUntilChanged()
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .bind(to: viewModel.isSwitchedOnRelay)
                .disposed(by: disposeBag)
            
            viewModel.isOn
                .drive(switchView.rx.value)
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
