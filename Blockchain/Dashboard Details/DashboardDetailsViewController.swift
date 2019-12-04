//
//  DashboardDetailsViewController.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

final class DashboardDetailsViewController: BaseScreenViewController {
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: SelfSizingTableView!
    @IBOutlet private var swapButtonView: ButtonView!
    
    // MARK: - Injected
    
    private let presenter: DashboardDetailsScreenPresenter

    // MARK: - Setup
    
    init(using presenter: DashboardDetailsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: DashboardDetailsViewController.objectName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        swapButtonView.viewModel = presenter.swapButtonViewModel
        presenter.refresh()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 312
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNibCell(MultiActionTableViewCell.objectName)
        tableView.registerNibCell(PriceAlertTableViewCell.objectName)
        tableView.registerNibCell(AssetLineChartTableViewCell.objectName)
        tableView.registerNibCell(CurrentBalanceTableViewCell.objectName)
        tableView.separatorColor = .clear
        presenter.isScrollEnabled
            .drive(tableView.rx.isScrollEnabled)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = presenter.titleView
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DashboardDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .sendRequest:
            cell = multiActionCell(for: indexPath, presenter: presenter.sendRequestPresenter)
        case .priceAlert:
            cell = priceAlertCell(for: indexPath)
        case .balance:
            cell = currentBalanceCell(for: indexPath)
        case .chart:
            cell = assetLineChartCell(for: indexPath, presenter: presenter.lineChartCellPresenter)
        }
        cell.selectionStyle = .none
        return cell
    }
        
    // MARK: - Accessors
    
    private func priceAlertCell(for indexPath: IndexPath) -> PriceAlertTableViewCell {
        let cell = tableView.dequeue(PriceAlertTableViewCell.self, for: indexPath)
        return cell
    }
    
    private func multiActionCell(for indexPath: IndexPath, presenter: MultiActionViewPresenting) -> MultiActionTableViewCell {
        let cell = tableView.dequeue(MultiActionTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func currentBalanceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter.assetBalanceViewPresenter
        cell.currency = presenter.currency
        return cell
    }
    
    private func assetLineChartCell(for indexPath: IndexPath, presenter: AssetLineChartTableViewCellPresenter) -> AssetLineChartTableViewCell {
        let cell = tableView.dequeue(AssetLineChartTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
