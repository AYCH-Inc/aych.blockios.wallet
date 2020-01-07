//
//  AirdropStatusScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformUIKit

final class AirdropStatusScreenViewController: BaseScreenViewController {

    // MARK: - Private Properties
    
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    private let presenter: AirdropStatusScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: AirdropStatusScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: Self.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()

        presenter.backgroundImage
            .drive(backgroundImageView.rx.content)
            .disposed(by: disposeBag)

        presenter.image
            .drive(thumbImageView.rx.content)
            .disposed(by: disposeBag)

        presenter.title
            .drive(titleLabel.rx.content)
            .disposed(by: disposeBag)
        
        presenter.description
            .drive(descriptionLabel.rx.content)
            .disposed(by: disposeBag)

        presenter.cellPresenters
            .bind { [weak self] _ in
                self?.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.Airdrop.StatusScreen.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground),
            leadingButtonStyle: presenter.presentationType.leadingButton)
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.separatorColor = .lightBorder
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNibCell(AirdropStatusTableViewCell.objectName)
        tableView.allowsSelection = false
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AirdropStatusScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.cellPresentersValue.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(AirdropStatusTableViewCell.self, for: indexPath)
        cell.presenter = presenter.cellPresentersValue[indexPath.row]
        return cell
    }
}
