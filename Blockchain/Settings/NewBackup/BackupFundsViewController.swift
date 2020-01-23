//
//  BackupFundsViewController.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class BackupFundsViewController: BaseScreenViewController {
    
    // MARK: Private Properties
    
    private let presenter: BackupFundsScreenPresenter
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var startBackupButtonView: ButtonView!
    @IBOutlet private var dashedImageView: UIImageView!
    @IBOutlet private var lockIllustrationImageView: UIImageView!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var primaryDescriptionLabel: UILabel!
    @IBOutlet private var secondaryDescriptionLabel: UILabel!
    
    // MARK: - Setup
    
    init(router: BackupFundsRouterAPI) {
        self.presenter = BackupFundsScreenPresenter(router: router)
        super.init(nibName: BackupFundsViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        applyAnimation()
        title = LocalizationConstants.BackupFundsScreen.title
        subtitleLabel.content = presenter.subtitle
        primaryDescriptionLabel.content = presenter.primaryDescription
        secondaryDescriptionLabel.content = presenter.secondaryDescription
        startBackupButtonView.viewModel = presenter.startBackupButton
    }
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.BackupFundsScreen.title)
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .white),
            leadingButtonStyle: .back)
    }
    
    private func applyAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.lockIllustrationImageView.transform = .init(translationX: 0.0, y: 7.0)
        }, completion: nil)
    }
}
