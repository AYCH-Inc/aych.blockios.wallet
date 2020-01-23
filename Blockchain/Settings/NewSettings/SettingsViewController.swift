//
//  SettingsViewController.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

final class SettingsViewController: BaseScreenViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let presenter: SettingsScreenPresenter
    private let disposeBag = DisposeBag()
    
    // TODO: Move to presenter
    private lazy var router: SettingsRouter = {
        return SettingsRouter(rootViewController: self,
                              currencyRouting: AppCoordinator.shared,
                              tabSwapping: AppCoordinator.shared)
    }()
    
    // MARK: - Setup
    
    init(presenter: SettingsScreenPresenter = SettingsScreenPresenter()) {
        self.presenter = presenter
        super.init(nibName: SettingsViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.settings
        setupTableView()
        setupNavigationBar()
        presenter.refresh()
    }
    
    // MARK: - Private Functions
    
    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.settings)
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .background),
            leadingButtonStyle: .none)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 70
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNibCell(SwitchTableViewCell.objectName)
        tableView.registerNibCell(ClipboardTableViewCell.objectName)
        tableView.registerNibCell(BadgeTableViewCell.objectName)
        tableView.registerNibCell(PlainTableViewCell.objectName)
        tableView.registerHeaderView(TableHeaderView.objectName)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let section = presenter.sectionArrangement[section]
        return section.sectionCellCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.objectName) as? TableHeaderView else { return nil }
        let section = presenter.sectionArrangement[section]
        let viewModel = TableHeaderViewModel.settings(title: section.sectionTitle)
        header.viewModel = viewModel
        return header
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let section = presenter.sectionArrangement[indexPath.section]
        let cellType = section.cellArrangement[indexPath.row]
        switch cellType {
        case .badge(let type):
            cell = badgeCell(for: indexPath, type: type)
        case .clipboard(let type):
            cell = clipboardCell(for: indexPath, type: type)
        case .plain(let type):
            cell = plainCell(for: indexPath, type: type)
        case .switch(let type):
            cell = switchCell(for: indexPath, type: type)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = presenter.sectionArrangement[indexPath.section]
        let cellType = section.cellArrangement[indexPath.row]
        router.handle(selection: cellType)
    }
    
    private func switchCell(for indexPath: IndexPath, type: SettingsScreenPresenter.Section.CellType.SwitchCellType) -> SwitchTableViewCell {
        let cell = tableView.dequeue(SwitchTableViewCell.self, for: indexPath)
        switch type {
        case .emailNotifications:
            cell.presenter = presenter.emailNotificationsCellPresenter
        case .bioAuthentication:
            cell.presenter = presenter.bioAuthenticationCellPresenter
        case .swipeToReceive:
            cell.presenter = presenter.swipeReceiveCellPresenter
        }
        return cell
    }
    
    private func clipboardCell(for indexPath: IndexPath, type: SettingsScreenPresenter.Section.CellType.ClipboardCellType) -> ClipboardTableViewCell {
        let cell = tableView.dequeue(ClipboardTableViewCell.self, for: indexPath)
        cell.titleLabel.text = type.title
        return cell
    }
    
    private func plainCell(for indexPath: IndexPath, type: SettingsScreenPresenter.Section.CellType.PlainCellType) -> PlainTableViewCell {
        let cell = tableView.dequeue(PlainTableViewCell.self, for: indexPath)
        cell.titleLabel.text = type.title
        return cell
    }
    
    private func badgeCell(for indexPath: IndexPath, type: SettingsScreenPresenter.Section.CellType.BadgeCellType) -> BadgeTableViewCell {
        let cell = tableView.dequeue(BadgeTableViewCell.self, for: indexPath)
        switch type {
        case .limits:
            cell.presenter = presenter.limitsCellPresenter
        case .mobileVerification:
            cell.presenter = presenter.mobileCellPresenter
        case .twoStepVerification:
            cell.presenter = presenter.twoFactorCellPresenter
        case .emailVerification:
            cell.presenter = presenter.emailCellPresenter
        case .pitConnection:
            cell.presenter = presenter.pitCellPresenter
        case .recoveryPhrase:
            cell.presenter = presenter.recoveryCellPresenter
        case .currencyPreference:
            cell.presenter = presenter.preferredCurrencyCellPresenter
        }
        return cell
    }
}
