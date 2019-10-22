//
//  PasswordRequiredViewController.swift
//  Blockchain
//
//  Created by AlexM on 10/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

final class PasswordRequiredViewController: BaseScreenViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var passwordTextField: PasswordTextFieldView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var forgotPasswordButtonView: ButtonView!
    @IBOutlet private var forgetWalletDescriptionLabel: UILabel!
    @IBOutlet private var forgetWalletButtonView: ButtonView!
    
    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let presenter: PasswordRequiredScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: PasswordRequiredScreenPresenter = PasswordRequiredScreenPresenter()) {
        self.presenter = presenter
        super.init(nibName: PasswordRequiredViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle)
        titleViewStyle = presenter.titleStyle
        keyboardInteractionController = KeyboardInteractionController(in: self)
    
        passwordTextField.setup(
            viewModel: presenter.passwordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        continueButtonView.viewModel = presenter.continueButtonViewModel
        
        forgotPasswordButtonView.viewModel = presenter.forgotPasswordButtonViewModel
        forgetWalletButtonView.viewModel = presenter.forgetWalletButtonViewModel
        
        let descriptionFont = UIFont.mainMedium(14)
        
        descriptionLabel.text = presenter.description
        descriptionLabel.font = descriptionFont
        descriptionLabel.textColor = .descriptionText
        
        forgetWalletDescriptionLabel.text = presenter.forgetDescription
        forgetWalletDescriptionLabel.font = descriptionFont
        forgetWalletDescriptionLabel.textColor = .descriptionText
        
        [continueButtonView, forgotPasswordButtonView].forEach { [unowned self] button in
            button.viewModel.tapRelay
                .dismissKeyboard(using: self.keyboardInteractionController)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
}
