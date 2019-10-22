//
//  ManualPairingViewController.swift
//  Blockchain
//
//  Created by AlexM on 10/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

/// This view controller is responsible for pairing wallets manually using
/// Wallet identifier and password
final class ManualPairingViewController: BaseScreenViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var walletIdTextFieldView: TextFieldView!
    @IBOutlet private var passwordTextFieldView: TextFieldView!
    @IBOutlet private var buttonView: ButtonView!

    // MARK: - Injected
    
    private let presenter: ManualPairingScreenPresenter

    // MARK: - Accessors
    
    private var keyboardInteractionController: KeyboardInteractionController!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: ManualPairingScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: ManualPairingViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle, leadingButtonStyle: .back)
        titleViewStyle = presenter.titleStyle
        keyboardInteractionController = KeyboardInteractionController(in: self)
        walletIdTextFieldView.setup(
            viewModel: presenter.walletIdTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        passwordTextFieldView.setup(
            viewModel: presenter.passwordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        buttonView.viewModel = presenter.buttonViewModel
        buttonView.viewModel.tapRelay
            .dismissKeyboard(using: keyboardInteractionController)
            .subscribe()
            .disposed(by: disposeBag)
        presenter.viewDidLoad()
    }
}
