//
//  PairingIntroViewController.swift
//  Blockchain
//
//  Created by AlexM on 10/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// This view-controller represents the login screen
final class PairingIntroViewController: BaseScreenViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: InstructionTableView!
    @IBOutlet private var primaryButton: ButtonView!
    @IBOutlet private var secondaryButton: ButtonView!

    // MARK: - Injected
    
    private let presenter: PairingIntroScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: PairingIntroScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: PairingIntroViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle, leadingButtonStyle: .back)
        titleViewStyle = presenter.titleStyle
        primaryButton.viewModel = presenter.primaryButtonViewModel
        secondaryButton.viewModel = presenter.secondaryButtonViewModel
        tableView.viewModels = presenter.instructionViewModels
        
        /// The reason for calling `view.layoutIfNeeded()` + `tableView.relaodData()`
        /// is that the layout of `tableView` does not refresh properly
        /// The root cause couldn't be found
        view.layoutIfNeeded()
        tableView.reloadData()
    }
}
