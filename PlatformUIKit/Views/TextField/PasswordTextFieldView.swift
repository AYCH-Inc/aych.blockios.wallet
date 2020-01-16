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
        
        /// *NOTE:* If `isSecureTextEntry` is set to `true`, and the text field regains focus.
        /// After tapping a new value the text is entirely deleted and replaced with that new value.
        /// Tapping the `Backspace` key just deletes the current value - resulting in an empty input field.
        /// The problem is that when it happens `func textField(:_,shouldChangeCharactersIn:replacementString:) -> Bool`
        /// does not not receive the correct range of characters and therefore we cannot calculate the replacement text,
        /// and as consecuence we cannot show the currect score (Weak, Medium, Strong).
        /// That is why we need to monitor `UITextField.textDidChangeNotification` as well and check the value AFTER
        /// the change too.
        NotificationCenter.when(UITextField.textDidChangeNotification) { [weak self] _ in
            guard let self = self, self.isTextFieldFocused else { return }
            self.viewModel?.textFieldEdited(with: self.text)
        }
    }
    
    private func setupScoreLabel() {
        accessoryView.addSubview(scoreLabel)
        scoreLabel.layoutToSuperview(axis: .horizontal)
        scoreLabel.layoutToSuperview(axis: .vertical)
        scoreLabel.font = .mainMedium(16)
    }
    
    private func setupPasswordStrengthIndicatorView() {
        addSubview(passwordStrengthIndicatorView)
        passwordStrengthIndicatorView.layoutToSuperview(axis: .horizontal)
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
