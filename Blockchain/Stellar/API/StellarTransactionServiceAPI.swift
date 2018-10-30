//
//  StellarTransactionServiceAPI.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class StellarTransactionServiceAPI: SimpleListServiceAPI {
    
    fileprivate let provider: XLMServiceProvider
    fileprivate let service: StellarOperationService
    fileprivate let disposables = CompositeDisposable()
    
    init(provider: XLMServiceProvider = XLMServiceProvider.shared) {
        self.provider = provider
        self.service = provider.services.operation
    }

    func fetchAllItems(output: SimpleListOutput?) {
        
        let disposable = service.operations
            .map { $0 }
            .scan([], accumulator: {
                return $0 + $1
            })
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                output?.loadedItems(result)
            }, onError: { error in
                output?.itemFetchFailed(error: error)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func refresh(output: SimpleListOutput?) {
        fetchAllItems(output: output)
    }
    
    func nextPageBefore(identifier: String) {
        // TODO: Not necessary given that we aren't paginating
    }

    func cancel() {
        // TODO: May not be necessary
    }

    func canPage() -> Bool {
        // You should never be able to page when looking at
        // XLM transactions given that we are polling the endpoint
        // and not using traditional pagination. 
        return false
    }

    deinit {
        disposables.dispose()
    }
}
