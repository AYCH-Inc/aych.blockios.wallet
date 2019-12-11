//
//  PasswordViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class PasswordViewController: BaseScreenViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var textFieldView: PasswordTextFieldView!
    @IBOutlet private var buttonView: ButtonView!

    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let presenter: PasswordScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: PasswordScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: PasswordViewController.objectName, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle, leadingButtonStyle: .close)
        titleViewStyle = presenter.titleStyle
        keyboardInteractionController = KeyboardInteractionController(in: self)
        
        descriptionLabel.text = presenter.description
        descriptionLabel.font = .mainMedium(14)
        descriptionLabel.textColor = .descriptionText
    
        textFieldView.setup(
            viewModel: presenter.textFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        
        buttonView.viewModel = presenter.buttonViewModel
        buttonView.viewModel.tapRelay
            .dismissKeyboard(using: keyboardInteractionController)
            .subscribe()
            .disposed(by: self.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }
}
