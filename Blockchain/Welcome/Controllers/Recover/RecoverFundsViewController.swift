//
//  RecoverFundsViewController.swift
//  Blockchain
//
//  Created by AlexM on 10/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import UIKit
import RxSwift
import RxCocoa

final class RecoverFundsViewController: BaseScreenViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var mnemonicTextView: MnemonicTextView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var continueButtonView: ButtonView!
    
    private var keyboardInteractionController: KeyboardInteractionController!
    
    // MARK: - Injected
    
    private let presenter: RecoverFundsScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: RecoverFundsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: RecoverFundsViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle, leadingButtonStyle: .back)
        titleViewStyle = presenter.titleStyle
        descriptionLabel.textColor = .descriptionText
        keyboardInteractionController = KeyboardInteractionController(in: self)
        continueButtonView.viewModel = presenter.continueButtonViewModel
        mnemonicTextView.setup(
            viewModel: presenter.mnemonicTextViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
    }
}
