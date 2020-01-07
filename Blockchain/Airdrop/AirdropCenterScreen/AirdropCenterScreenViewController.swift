//
//  AirdropCenterScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformUIKit

final class AirdropCenterScreenViewController: BaseScreenViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Injected
    
    private let presenter: AirdropCenterScreenPresenter
    
    // MARK: - Setup
    
    init(presenter: AirdropCenterScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: Self.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = presenter.backgroundColor
        setupNavigationBar()
        setupTableView()
        presenter.refresh()
    }
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.Airdrop.CenterScreen.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground),
            leadingButtonStyle: .close)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .mediumBorder
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 32
        tableView.registerNibCell(AirdropTypeTableViewCell.objectName)
        tableView.register(SimpleHeaderView.self)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AirdropCenterScreenViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeue(SimpleHeaderView.self)
        headerView.text = presenter.dataSource[section].title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(AirdropTypeTableViewCell.self, for: indexPath)
        cell.presenter = cellPresenter(by: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.presenterSelectionRelay.accept(cellPresenter(by: indexPath))
    }
    
    // MARK: - TableView accessors
    
    private func cellPresenter(by indexPath: IndexPath) -> AirdropTypeCellPresenter {
        return presenter.dataSource[indexPath.section].items[indexPath.row]
    }
}
