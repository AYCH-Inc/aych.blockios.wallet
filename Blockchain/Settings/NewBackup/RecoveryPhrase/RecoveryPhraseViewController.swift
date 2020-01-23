//
//  RecoveryPhraseViewController.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class RecoveryPhraseViewController: BaseScreenViewController {
    
    // MARK: Private Properties
    
    private let presenter: RecoveryPhraseScreenPresenter
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var recoveryPhraseView: RecoveryPhraseView!
    @IBOutlet private var nextButtonView: ButtonView!
    
    // MARK: - Setup
    
    init(router: RecoveryPhraseRouterAPI) {
        self.presenter = RecoveryPhraseScreenPresenter(router: router, mnemonicAPI: WalletManager.shared.wallet)
        super.init(nibName: RecoveryPhraseViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        title = presenter.title
        subtitleLabel.content = presenter.subtitle
        descriptionLabel.content = presenter.description
        recoveryPhraseView.viewModel = presenter.recoveryViewModel
        nextButtonView.viewModel = presenter.nextViewModel
    }
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .white),
            leadingButtonStyle: .back)
    }
    
}
