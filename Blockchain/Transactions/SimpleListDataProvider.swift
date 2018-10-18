//
//  SimpleListDataProvider.swift
//  Blockchain
//
//  Created by kevinwu on 10/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

protocol SimpleListDataProviderDelegate: class {
    func dataProvider(_ dataProvider: SimpleListDataProvider, nextPageBefore item: AnyObject)
    func dataProvider(_ dataProvider: SimpleListDataProvider, didSelect item: AnyObject)
    func refreshControlTriggered(_ dataProvider: SimpleListDataProvider)

    var estimatedCellHeight: CGFloat { get }
}

// A data provider for a simple table view that is
// - refreshable by pulling down
// - able to trigger the next page by scrolling to the bottom
class SimpleListDataProvider: NSObject {

    // MARK: Public

    weak var delegate: SimpleListDataProviderDelegate?

    // If this is `true` we should show the cell with
    // a loading indicator at the bottom of the `tableView`
    var isPaging: Bool = false {
        didSet {
            guard let table = tableView else { return }
            guard let current = models else { return }
            guard isPaging != oldValue else { return }
            table.beginUpdates()
            let path = IndexPath(row: current.count, section: 1)
            switch isPaging {
            case true:
                table.insertRows(at: [path], with: .automatic)
            case false:
                table.deleteRows(at: [path], with: .automatic)
            }
            table.endUpdates()
        }
    }

    var isRefreshing: Bool = false {
        didSet {
            guard let refresh = refreshControl else { return }
            switch isRefreshing {
            case true:
                refresh.beginRefreshing()
            case false:
                refresh.endRefreshing()
            }
        }
    }

    // MARK: Private Properties

    fileprivate weak var tableView: UITableView?
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var models: [AnyObject]?
    fileprivate var estimatedCellHeight: CGFloat {
        return delegate?.estimatedCellHeight ?? 44.0
    }

    init(table: UITableView) {
        tableView = table
        super.init()
        tableView?.estimatedRowHeight = estimatedCellHeight
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        registerAllCellTypes()
    }

    fileprivate func registerAllCellTypes() {
        // Logger.shared.error("Not overridden by superclass!")
    }

    func setupPullToRefresh() {
        guard refreshControl == nil else { return }
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = control
        tableView?.refreshControl = refreshControl
    }

    func set(listModels: [AnyObject]) {
        models = listModels
        tableView?.reloadData()
    }

    func append(listModels: [AnyObject]) {
        if var current = models {
            current.append(contentsOf: listModels)
            models = current
        } else {
            models = listModels
        }
        tableView?.reloadData()
    }

    @objc fileprivate func refresh() {
        delegate?.refreshControlTriggered(self)
    }
}

extension SimpleListDataProvider: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let items = models else { return 1 }
        return items.count > 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            guard let current = models else { return 0 }
            return isPaging ? current.count + 1 : current.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Logger.shared.error("Not overridden by superclass!")

        // Keeping this code commented to because it deals with paging
        //
        //        if indexPath.row == items.count && isPaging {
        //            guard let cell = tableView.dequeueReusableCell(
        //                withIdentifier: loadingIdentifier,
        //                for: indexPath
        //                ) as? LoadingTableViewCell else { return UITableViewCell() }
        //
        //            /// This particular cell shouldn't have a separator.
        //            /// This is how we hide it.
        //            cell.separatorInset = UIEdgeInsets(
        //                top: 0.0,
        //                left: 0.0,
        //                bottom: 0.0,
        //                right: .greatestFiniteMagnitude
        //            )
        //            return cell
        //        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = models else { return }
        guard indexPath.section == 1 else { return }
        guard items.count > indexPath.row else { return }
        let model = items[indexPath.row]
        delegate?.dataProvider(self, didSelect: model)
    }
}

extension SimpleListDataProvider: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Keeping this code commented to because it deals with paging
        // return isPaging ? LoadingTableViewCell.height() : 0.0
        return estimatedCellHeight
    }
}

extension SimpleListDataProvider: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            guard let item = models?.last else { return }
            delegate?.dataProvider(self, nextPageBefore: item)
        }
    }
}
