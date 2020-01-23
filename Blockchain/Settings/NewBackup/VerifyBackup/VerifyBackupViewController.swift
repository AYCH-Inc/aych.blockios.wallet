//
//  VerifyBackupViewController.swift
//  Blockchain
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit

final class VerifyBackupViewController: BaseScreenViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var buttonView: ButtonView!
    
    // MARK: - Private IBOutlets (UILabel)
    
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var firstNumberLabel: UILabel!
    @IBOutlet private var secondNumberLabel: UILabel!
    @IBOutlet private var thirdNumberLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    
    // MARK: - Private IBOutlets (TextFieldView)
    
    @IBOutlet private var firstTextFieldView: ValidationTextFieldView!
    @IBOutlet private var secondTextFieldView: ValidationTextFieldView!
    @IBOutlet private var thirdTextFieldView: ValidationTextFieldView!
    
    // MARK: - Private Properties
    
    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let presenter: VerifyBackupScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: VerifyBackupScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: VerifyBackupViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        keyboardInteractionController = KeyboardInteractionController(in: self)
        
        descriptionLabel.content = presenter.descriptionLabel
        
        firstNumberLabel.content = presenter.firstNumberLabel
        secondNumberLabel.content = presenter.secondNumberLabel
        thirdNumberLabel.content = presenter.thirdNumberLabel
        errorLabel.content = presenter.errorLabel
        
        firstTextFieldView.setup(
            viewModel: presenter.firstTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        secondTextFieldView.setup(
            viewModel: presenter.secondTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        
        thirdTextFieldView.setup(
            viewModel: presenter.thirdTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        
        buttonView.viewModel = presenter.verifyButtonViewModel
        
        presenter.errorDescriptionVisibility
            .map { $0.isHidden }
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.VerifyBackupScreen.title)
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .white),
            leadingButtonStyle: .back)
    }
}
