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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// The reason for calling `tableView.reloadData()`
        /// is that the layout of `tableView` does not refresh properly and because
        /// the width of the cells are not known, the height of the attributed text
        /// cannot be accurately calculated. Reloading the data solves it.
        tableView.reloadData()
    }
}
