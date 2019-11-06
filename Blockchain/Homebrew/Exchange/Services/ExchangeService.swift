//
//  ExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

typealias CompletionHandler = ((Result<[ExchangeTradeCellModel], Error>) -> Void)

protocol ExchangeHistoryAPI {
    
    var tradeModels: [ExchangeTradeCellModel] { get set }
    var canPage: Bool { get set }
    
    func hasExecutedTrades() -> Single<Bool>
    func getHomebrewTrades(before date: Date, completion: @escaping CompletionHandler)
    func getAllTrades(with completion: @escaping CompletionHandler)
    
    func cancel()
}

class ExchangeService: NSObject {
    
    /// Note: Don't use the `shared` instance unless absolutely necessary
    /// this is only being used in `CardsViewController+KYC` because
    /// `CardsViewController` is an ObjC class and extensions
    /// cannot have stored properties. 
    static let shared = ExchangeService()
    
    typealias CompletionHandler = ((Result<[ExchangeTradeCellModel], Error>) -> Void)
    
    var tradeModels: [ExchangeTradeCellModel] {
        get {
            return _tradeModels.value
        }
        set {
            _tradeModels.mutate { $0 = newValue }
        }
    }
    
    var canPage: Bool {
        get {
            return _canPage.value
        }
        set {
            _canPage.mutate { $0 = newValue }
        }
    }
    
    private var _tradeModels: Atomic<[ExchangeTradeCellModel]> = Atomic([])
    private var _canPage: Atomic<Bool> = Atomic(false)
    
    private let homebrewAPI: HomebrewExchangeAPI = HomebrewExchangeService()
    private var homebrewOperation: AsyncBlockOperation!
    
    private let queue = DispatchQueue(label: "com.blockchain.ExchangeService.access")
    
    private let tradeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    private func sort(models: [ExchangeTradeCellModel]) -> [ExchangeTradeCellModel] {
        let sorted = models.sorted(by: { $0.transactionDate.compare($1.transactionDate) == .orderedDescending })
        return sorted
    }
}

extension ExchangeService: ExchangeHistoryAPI {
    
    func hasExecutedTrades() -> Single<Bool> {
        // Don't bother checking for trades if not empty, since we are only interested
        // if the user has trades of not
        guard tradeModels.isEmpty else { return .just(true) }
        return Single.create(subscribe: { [weak self] event -> Disposable in
            guard let this = self else { return Disposables.create() }
            this.getAllTrades(with: { result in
                switch result {
                case .success(let models):
                    let hasExecuted = models.count > 0
                    event(.success(hasExecuted))
                case .failure:
                    event(.success(false))
                }
            })
            return Disposables.create()
        })
    }
    
    func getHomebrewTrades(before date: Date = Date(), completion: @escaping CompletionHandler) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            guard self.isExecuting() == false else { return }
            
            if let op = self.homebrewOperation {
                guard op.isExecuting == false else { return }
            }
            
            var result: Result<[ExchangeTradeCellModel], Error> = .failure(NSError())
            self.homebrewOperation = AsyncBlockOperation(executionBlock: { complete in
                self.homebrewAPI.nextPage(fromTimestamp: date, completion: { payload in
                    result = payload
                    switch result {
                    case .success(let value):
                        self._canPage.mutate { $0 = value.count >= 50 }
                        self._tradeModels.mutate { $0.append(contentsOf: value) }
                    case .failure:
                        self._canPage.mutate { $0 = false }
                    }
                    complete()
                })
            })
            self.homebrewOperation.addCompletionBlock {
                if case let .success(value) = result {
                    let models = self.sort(models: value)
                    completion(.success(models))
                } else {
                    completion(result)
                }
            }
            self.homebrewOperation.start()
        }
    }
    
    func getAllTrades(with completion: @escaping CompletionHandler) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            /// Trades are being fetched, bail early.
            guard self.isExecuting() == false else { return }
            self.tradeModels = []
            
            self.homebrewOperation = AsyncBlockOperation(executionBlock: { complete in
                self.homebrewAPI.nextPage(fromTimestamp: Date(), completion: { result in
                    switch result {
                    case .success(let value):
                        self._canPage.mutate { $0 = value.count >= 50 }
                        self._tradeModels.mutate { $0.append(contentsOf: value) }
                    case .failure(let error):
                        self._canPage.mutate { $0 = false }
                        completion(.failure(error))
                    }
                    complete()
                })
            })
            self.homebrewOperation.addCompletionBlock {
                self._tradeModels.mutate { $0 = self.sort(models: $0) }
                completion(.success(self._tradeModels.value))
            }
            
            self.tradeQueue.addOperations([self.homebrewOperation], waitUntilFinished: false)
        }
    }
    
    
    func cancel() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            guard self.isExecuting() else { return }
            
            self.tradeQueue.operations.forEach({$0.cancel()})
        }
    }
    
    // MARK: - Private methods
    
    private func isExecuting() -> Bool {
        guard let homebrew = homebrewOperation else {
            return tradeQueue.operationCount > 0
        }
        return tradeQueue.operations.count > 0 || homebrew.isExecuting
    }
    
}
