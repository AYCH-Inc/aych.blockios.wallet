//
//  Airdrop.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

// TODO: Finish the airdrop screens
final class AirdropIntroViewController: BaseScreenViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var disclaimerTextView: InteractableTextView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var buttonView: ButtonView!
    
    private let presenter: AirdropIntroScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: AirdropIntroScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: AirdropIntroViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountLabel.content = presenter.amount
        titleLabel.content = presenter.title
        subtitleLabel.content = presenter.subtitle
        disclaimerTextView.viewModel = presenter.disclaimerViewModel
        buttonView.viewModel = presenter.buttonViewModel
        view.layoutIfNeeded()
        disclaimerTextView.setupHeight()
        setupTableView()
    }
    
    private func setupTableView() {
        
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AirdropIntroViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
