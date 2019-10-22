//
//  WelcomeViewController.swift
//  Blockchain
//
//  Created by AlexM on 10/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class WelcomeViewController: BaseScreenViewController {
    
    // MARK: Private IBOutlets
        
    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var versionLabel: UILabel!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var createWalletButtonView: ButtonView!
    @IBOutlet private var loginButtonView: ButtonView!
    @IBOutlet private var recoverFundsButtonView: ButtonView!
    
    // MARK: Private Properties
    
    private let presenter: WelcomeScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: WelcomeScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: String(describing: WelcomeViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle)
        welcomeLabel.font = .mainSemibold(24)
        welcomeLabel.text = presenter.title
        descriptionLabel.attributedText = presenter.description
        versionLabel.textColor = .mutedText
        versionLabel.text = presenter.version
        createWalletButtonView.viewModel = presenter.createWalletButtonViewModel
        loginButtonView.viewModel = presenter.loginButtonViewModel
        recoverFundsButtonView.viewModel = presenter.recoverFundsButtonViewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        fadeIn()
    }
    
    private func fadeIn() {
        let fade = { (alpha: CGFloat) -> Void in
            self.welcomeLabel.alpha = alpha
            self.descriptionLabel.alpha = alpha
            self.stackView.alpha = alpha
        }
        fade(0)
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [.curveEaseOut],
            animations: { fade(1) },
            completion: nil)
    }
}

// MARK: - Dev Support

#if DEBUG
extension WelcomeViewController {
    override var canBecomeFirstResponder: Bool { return true }
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            presenter.devSupport.showDebugView(from: .welcome)
        default:
            break
        }
    }
}
#endif
