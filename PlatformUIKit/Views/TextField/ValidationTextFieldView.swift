//
//  ValidationTextFieldView.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class ValidationTextFieldView: TextFieldView {
    
    // MARK: - Exposed Properties
    
    private var viewModel: ValidationTextFieldViewModel!
    
    // MARK: - Private Properties
    
    private let invalidImageView = UIImageView(image: #imageLiteral(resourceName: "validation-error"))
    private var disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    override func setup() {
        super.setup()
        setupImageView()
    }
    
    private func setupImageView() {
        invalidImageView.contentMode = .scaleAspectFit
        accessoryView.addSubview(invalidImageView)
        invalidImageView.layout(size: .init(width: 24, height: 20))
        invalidImageView.layoutToSuperview(.centerX, .centerY)
        invalidImageView.horizontalContentCompressionResistancePriority = .penultimate
    }
    
    public func setup(viewModel: ValidationTextFieldViewModel,
                      keyboardInteractionController: KeyboardInteractionController) {
        super.setup(viewModel: viewModel, keyboardInteractionController: keyboardInteractionController)
        self.viewModel = viewModel
        
        // Bind score title to score label
        self.viewModel.accessoryVisibility
            .map { $0.defaultAlpha }
            .drive(accessoryView.rx.alpha)
            .disposed(by: disposeBag)
    }
}

