//
//  SegmentedView.swift
//  PlatformUIKit
//
//  Created by AlexM on 11/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

/// The standard wallet `UISegmentedControl` containerView.
/// - see also: [SegmentedViewModel](x-source-tag://SegmentedViewModel).
public final class SegmentedView: UIView {
    
    // MARK: - UI Properties
    
    @IBOutlet private var segmentedControl: UISegmentedControl!
    
    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    
    public var viewModel: SegmentedViewModel! {
        didSet {
            
            disposeBag = DisposeBag()
            
            layer.cornerRadius = viewModel.cornerRadius
            
            // Set accessibility
            accessibility = viewModel.accessibility
            
            // Bind backgroundColor
            viewModel.backgroundColor
                .drive(segmentedControl.rx.backgroundImageFillColor)
                .disposed(by: disposeBag)
            
            // Set the divider color
            viewModel.dividerColor
                .drive(segmentedControl.rx.dividerColor)
                .disposed(by: disposeBag)
            
            // Set the text attributes
            Driver
                .zip(viewModel.contentColor, viewModel.normalFont)
                .map { tuple -> [NSAttributedString.Key: Any]? in
                    var attributes: [NSAttributedString.Key: Any] = [:]
                    attributes[.font] = tuple.1
                    if let color = tuple.0 {
                        attributes[.foregroundColor] = color
                    }
                    return attributes
                }
                .drive(segmentedControl.rx.normalTextAttributes)
                .disposed(by: disposeBag)
            
            Driver
                .zip(viewModel.selectedFontColor, viewModel.selectedFont)
                .map { tuple -> [NSAttributedString.Key: Any]? in
                    var attributes: [NSAttributedString.Key: Any] = [:]
                    attributes[.font] = tuple.1
                    if let color = tuple.0 {
                        attributes[.foregroundColor] = color
                    }
                    return attributes
                }
                .drive(segmentedControl.rx.selectedTextAttributes)
                .disposed(by: disposeBag)
            
            // Bind border color
            viewModel.borderColor
                .drive(layer.rx.borderColor)
                .disposed(by: disposeBag)
            
            // Bind view model enabled indication to button
            viewModel.isEnabled
                .drive(segmentedControl.rx.isEnabled)
                .disposed(by: disposeBag)
            
            // Bind opacity
            viewModel.alpha
                .drive(rx.alpha)
                .disposed(by: disposeBag)
            
            segmentedControl.rx.value
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)
                
            segmentedControl.isMomentary = viewModel.isMomentary
            
            segmentedControl.removeAllSegments()
            viewModel.items.enumerated().forEach {
                switch $1.content {
                case .imageName(let imageName):
                    segmentedControl.insertSegment(with: UIImage(named: imageName), at: $0, animated: false)
                case .title(let title):
                    segmentedControl.insertSegment(withTitle: title, at: $0, animated: false)
                }
            }
            
            guard segmentedControl.isMomentary == false else { return }
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.sendActions(for: .valueChanged)
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
        layer.borderWidth = 1
    }
}
