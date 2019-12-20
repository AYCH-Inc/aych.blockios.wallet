//
//  ExchangeListViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import PlatformKit

protocol ExchangeListDelegate: class {
    func onLoaded()
    func onDisappear()
    func onNextPageRequest(_ identifier: String)
    func onTradeCellTapped(_ trade: ExchangeTradeCellModel)
    func onPullToRefresh()
}

class ExchangeListViewController: UIViewController {
    
    // MARK: Public Properties
    
    weak var delegate: ExchangeListDelegate?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var dataProvider: ExchangeListDataProvider?
    fileprivate var presenter: ExchangeListPresenter!
    fileprivate var dependencies: ExchangeDependencies!
    
    // MARK: Factory
    
    class func make(with dependencies: ExchangeDependencies) -> ExchangeListViewController {
        let controller = ExchangeListViewController.makeFromStoryboard()
        controller.dependencies = dependencies
        AnalyticsService.shared.trackEvent(title: "exchange_history")
        return controller
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider = ExchangeListDataProvider(table: tableView)
        dependenciesSetup()
        dataProvider?.delegate = self
        delegate?.onLoaded()
        registerForNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = LocalizationConstants.Swap.swap
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.onDisappear()
    }
    
    fileprivate func dependenciesSetup() {
        let interactor = ExchangeListInteractor(dependencies: dependencies)
        presenter = ExchangeListPresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.when(Constants.NotificationKeys.exchangeSubmitted) { [weak self] _ in
            guard let this = self else { return }
            this.delegate?.onLoaded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ExchangeListViewController: ExchangeListInterface {
    func showTradeDetails(trade: ExchangeTradeCellModel) {
        let model = ExchangeDetailPageModel(type: .overview(trade))
        let detailViewController = ExchangeDetailViewController.make(
            with: model,
            dependencies: ExchangeServices()
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func paginationActivityIndicatorVisibility(_ visibility: Visibility) {
        dataProvider?.isPaging = visibility == .visible
    }
    
    func refreshControlVisibility(_ visibility: Visibility) {
        dataProvider?.isRefreshing = visibility.isHidden == false
    }
    
    func display(results: [ExchangeTradeCellModel]) {
        dataProvider?.set(tradeModels: results)
    }
    
    func append(results: [ExchangeTradeCellModel]) {
        dataProvider?.append(tradeModels: results)
    }
    
    func enablePullToRefresh() {
        dataProvider?.setupPullToRefresh()
    }
    
    func showNewExchange(animated: Bool) {
        
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message)
    }
}

extension ExchangeListViewController: ExchangeListDataProviderDelegate {
    func dataProvider(_ dataProvider: ExchangeListDataProvider, didSelect trade: ExchangeTradeCellModel) {
        dependencies.analyticsRecorder.record(event: AnalyticsEvents.Swap.swapHistoryOrderClick)
        delegate?.onTradeCellTapped(trade)
    }
    
    func refreshControlTriggered(_ dataProvider: ExchangeListDataProvider) {
        delegate?.onPullToRefresh()
    }
    
    func dataProvider(_ dataProvider: ExchangeListDataProvider, nextPageBefore identifier: String) {
        delegate?.onNextPageRequest(identifier)
    }
}

extension ExchangeListViewController: NavigatableView {
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        // No-Op
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        dismiss(animated: true, completion: nil)
    }
    
    var leftNavControllerCTAType: NavigationCTAType {
        return .dismiss
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .none
    }
}
