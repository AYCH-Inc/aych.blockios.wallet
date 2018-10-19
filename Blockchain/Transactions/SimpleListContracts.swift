//
//  SimpleListContracts.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SimpleListInterface: class {
    func paginationActivityIndicatorVisibility(_ visibility: Visibility)
    func refreshControlVisibility(_ visibility: Visibility)
    func display(results: [AnyObject])
    func append(results: [AnyObject])
    func enablePullToRefresh()
    func showItemDetails(item: AnyObject)
    func showError(message: String)
}

protocol SimpleListInput: class {
    func canPage() -> Bool
    func fetchAllItems()
    func refresh()
    func cancel()
    func itemSelectedWith(identifier: String) -> AnyObject?
    func nextPageBefore(identifier: String)
}

protocol SimpleListOutput: class {
    func willApplyUpdate()
    func didApplyUpdate()
    func loadedItems(_ items: [AnyObject])
    func appendItems(_ items: [AnyObject])
    func refreshedItems(_ items: [AnyObject])
    func itemWithIdentifier(_ identifier: String) -> AnyObject?
    func itemFetchFailed(error: Error?)
}
