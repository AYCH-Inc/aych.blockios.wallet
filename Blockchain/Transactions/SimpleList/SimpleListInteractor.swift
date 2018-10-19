//
//  SimpleListInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class SimpleListInteractor: SimpleListInput {
    fileprivate var service: SimpleListServiceAPI?

    weak var output: SimpleListOutput?

    init(listService: SimpleListServiceAPI) {
        self.service = listService
    }

    func fetchAllItems() {
        service?.fetchAllItems(output: output)
    }

    func refresh() {
        service?.refresh(output: output)
    }

    func canPage() -> Bool {
        return false
    }

    func itemSelectedWith(identifier: String) -> Identifiable? {
        return nil
    }

    func nextPageBefore(identifier: String) {
        service?.nextPageBefore(identifier: identifier)
    }

    func cancel() {
        service?.cancel()
    }
}
