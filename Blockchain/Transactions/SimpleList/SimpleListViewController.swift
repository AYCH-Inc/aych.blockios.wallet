//
//  SimpleListViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SimpleListDelegate: class {
    func onLoaded()
    func onDisappear()
    func onNextPageRequest(_ identifier: String)
    func onItemCellTapped(_ item: Identifiable)
    func onPullToRefresh()
}

// A view controller for a simple table view that is
// - refreshable by pulling down
// - able to trigger the next page by scrolling to the bottom
class SimpleListViewController: UIViewController {

    // MARK: Public Properties

    weak var delegate: SimpleListDelegate?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var dataProvider: SimpleListDataProvider?
    fileprivate var presenter: SimpleListPresenter!
    // Unsure of how to genericize this
    // fileprivate var dependencies: ExchangeDependencies!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider = SimpleListDataProvider(table: tableView)
        dependenciesSetup()
        dataProvider?.delegate = self
        delegate?.onLoaded()
    }

    fileprivate func dependenciesSetup() {
//        let interactor = SimpleListInteractor(dependencies: dependencies)
//        presenter = SimpleListPresenter(interactor: interactor)
//        presenter.interface = self
//        interactor.output = presenter
//        delegate = presenter
    }
}

extension SimpleListViewController: SimpleListInterface {
    func paginationActivityIndicatorVisibility(_ visibility: Visibility) {
        dataProvider?.isPaging = visibility == .visible
    }

    func refreshControlVisibility(_ visibility: Visibility) {
        dataProvider?.isRefreshing = visibility.isHidden == false
    }

    func display(results: [Identifiable]) {
        dataProvider?.set(listModels: results)
    }

    func append(results: [Identifiable]) {
        dataProvider?.append(listModels: results)
    }

    func enablePullToRefresh() {
        dataProvider?.setupPullToRefresh()
    }

    func showItemDetails(item: Identifiable) {
        // in ExchangeList example, message is sent to coordinator
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message)
    }
}

extension SimpleListViewController: SimpleListDataProviderDelegate {
    func dataProvider(_ dataProvider: SimpleListDataProvider, nextPageBefore identifier: String) {
        delegate?.onNextPageRequest(identifier)
    }

    func dataProvider(_ dataProvider: SimpleListDataProvider, didSelect item: Identifiable) {
        delegate?.onItemCellTapped(item)
    }

    func refreshControlTriggered(_ dataProvider: SimpleListDataProvider) {
        delegate?.onPullToRefresh()
    }

    var estimatedCellHeight: CGFloat {
        return 44.0
    }
}
