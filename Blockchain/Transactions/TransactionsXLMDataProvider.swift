//
//  TransactionsXLMDataProvider.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsXLMDataProvider: SimpleListDataProvider {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = models else { return UITableViewCell() }

        if items.count > indexPath.row {
            let model = items[indexPath.row]
            return UITableViewCell()
        }

        if indexPath.row == items.count && isPaging {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        return UITableViewCell()
    }
}
