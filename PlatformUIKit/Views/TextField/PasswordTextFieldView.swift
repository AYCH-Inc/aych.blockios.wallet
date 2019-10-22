//
//  PasswordTextFieldView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class PasswordTextFieldView: TextFieldView {
    
    // MARK: - Exposed Properties
    
    private var viewModel: PasswordTextFieldViewModel!
    
    // MARK: - Private IBOutlets
    
    private let passwordStrengthIndicatorView = UIProgressView(progressViewStyle: .bar)
    
    // MARK: - Private Properties
    
    private let scoreLabel = UILabel()
    private var disposeBag = DisposeBag()
    
    fileprivate var scoreViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Setup
    
    override func setup() {
        super.setup()
        setupScoreLabel()
        setupPasswordStrengthIndicatorView()
    }
    
    private func setupScoreLabel() {
        accessoryView.addSubview(scoreLabel)
        scoreLabel.layoutToSuperview(.horizontal, .vertical)
        scoreLabel.font = .mainMedium(16)
    }
    
    private func setupPasswordStrengthIndicatorView() {
        addSubview(passwordStrengthIndicatorView)
        passwordStrengthIndicatorView.layoutToSuperview(.horizontal)
        NSLayoutConstraint.activate([
            passwordStrengthIndicatorView.heightAnchor.constraint(equalToConstant: 1),
            passwordStrengthIndicatorView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor)
        ])
    }
    
    public func setup(viewModel: PasswordTextFieldViewModel,
                      keyboardInteractionController: KeyboardInteractionController) {
        super.setup(viewModel: viewModel, keyboardInteractionController: keyboardInteractionController)
        self.viewModel = viewModel
        
        // Bind score title to score label
        self.viewModel.score
            .map { $0.title }
            .bind(to: scoreLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Bind score color to score label
        self.viewModel.score
            .map { $0.color }
            .bind(to: scoreLabel.rx.textColor, passwordStrengthIndicatorView.rx.fillColor)
            .disposed(by: disposeBag)
        
        // Bind score color to score label
        self.viewModel.score
            .map { Float($0.progress) }
            .bind(to: passwordStrengthIndicatorView.rx.progress)
            .disposed(by: disposeBag)
    }
}
