//
//  DashboardViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxRelay
import PlatformKit
import RxCocoa

/// A view controller that displays thr dashboard
final class DashboardViewController: BaseScreenViewController {

    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    // MARK: - Injected
    
    private let presenter: DashboardScreenPresenter
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init() {
        self.presenter = DashboardScreenPresenter()
        super.init(nibName: DashboardViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        presenter.action
            .emit(onNext: { [weak self] action in
                self?.execute(action: action)
            })
            .disposed(by: disposeBag)
        presenter.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.navigationBar.isTranslucent = false
        presenter.refresh()
    }
        
    // MARK: - Setup
    
    private func setupNavigationBar() {
        set(barStyle: .lightContent(
                ignoresStatusBar: false,
                background: .navigationBarBackground
            ),
            leadingButtonStyle: .drawer,
            trailingButtonStyle: .qrCode)
        titleViewStyle = .text(value: LocalizationConstants.DashboardScreen.title)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AnnouncementTableViewCell.self)
        tableView.register(NoticeTableViewCell.self)
        tableView.registerNibCell(TotalBalanceTableViewCell.objectName)
        tableView.registerNibCell(HistoricalBalanceTableViewCell.objectName)
        tableView.separatorColor = .clear
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    
    private func execute(action: DashboardCollectionAction) {
        switch action {
        case .announcement(let announcementAction):
            execute(announcementAction: announcementAction)
        case .notice(let state):
            execute(noticeState: state)
        }
    }
    
    private func execute(noticeState: NoticeDisplayAction) {
        // Available cell after balance
        let index = presenter.indexByCellType[.balance]! + 1
        let indexPaths = [IndexPath(item: index, section: 0)]
        switch noticeState {
        case .show where presenter.noticeState == .hidden:
            tableView.insertRows(at: indexPaths, with: .automatic)
            presenter.noticeState = .visible
        case .hide where presenter.noticeState == .visible:
            tableView.deleteRows(at: indexPaths, with: .automatic)
            presenter.noticeState = .hidden
        default:
            break
        }
    }
    
    private func execute(announcementAction: AnnouncementDisplayAction) {
        switch announcementAction {
        case .hide where presenter.cardState == .visible:
            tableView.deleteFirst()
            presenter.cardState = .hidden
        case .show where presenter.cardState == .hidden:
            tableView.insertFirst()
            presenter.cardState = .visible
        default:
            break
        }
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.navigationBarTrailingButtonPressed()
    }
    
    // MARK: - UITableView refresh
    
    @objc
    private func refresh() {
        presenter.refresh()
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .announcement:
            cell = announcementCell(for: indexPath)
        case .balance:
            cell = balanceCell(for: indexPath)
        case .crypto(let currency):
            cell = assetCell(for: indexPath, currency: currency)
        case .notice:
            cell = noticeCell(for: indexPath)
        }
        return cell
    }
        
    // MARK: - Accessors
    
    private func announcementCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        cell.viewModel = presenter.announcementCardViewModel
        return cell
    }
    
    private func balanceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(TotalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter.totalBalancePresenter
        return cell
    }
    
    private func assetCell(for indexPath: IndexPath, currency: CryptoCurrency) -> UITableViewCell {
        let cell = tableView.dequeue(HistoricalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter.historicalBalancePresenter(by: indexPath.row)
        return cell
    }
    
    private func noticeCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(NoticeTableViewCell.self, for: indexPath)
        cell.viewModel = presenter.noticeViewModel
        return cell
    }
}
