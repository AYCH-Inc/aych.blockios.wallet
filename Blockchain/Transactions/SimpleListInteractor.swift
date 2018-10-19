//
//  SimpleListInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class SimpleListInteractor: SimpleListInput {
    fileprivate let service: SimpleHistoryAPI

    weak var output: SimpleListOutput?

    init(dependencies: SimpleDependencies) {
        self.service = dependencies.service
    }

    func fetchAllItems() {

    }

    func refresh() {

    }

    func canPage() -> Bool {
        return false
    }

    func itemSelectedWith(identifier: String) -> AnyObject? {

    }

    func nextPageBefore(identifier: String) {

    }

    func cancel() {

    }
}
