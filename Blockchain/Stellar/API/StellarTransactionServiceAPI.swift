//
//  StellarTransactionServiceAPI.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class StellarTransactionServiceAPI: SimpleListServiceAPI {
    private let service = StellarOperationService()

    func fetchAllItems(output: SimpleListOutput?) {
        guard service.isExecuting() == false else { return }
        service.operations(from: "accountID", token: "token") { result in
            switch result {
            case .success(let items):
                output?.loadedItems(items as! [Identifiable])
            case .error(let error):
                output?.itemFetchFailed(error: error)
            }
        }
    }

    func refresh(output: SimpleListOutput?) {
        guard service.isExecuting() == false else { return }
        service.operations(from: "accountID", token: "token") { (result) in
            switch result {
            case .success(let items):
                output?.refreshedItems(items as! [Identifiable])
            case .error(let error):
                output?.itemFetchFailed(error: error)
            }
        }
    }

    func nextPageBefore(identifier: String) {
    }

    func cancel() {
        guard service.isExecuting() else { return }
        service.cancel()
    }

    func canPage() -> Bool {
        return service.canPage
    }
}
