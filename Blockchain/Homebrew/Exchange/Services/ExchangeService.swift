//
//  ExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

typealias CompletionHandler = ((Result<[ExchangeTradeCellModel], Error>) -> Void)

protocol ExchangeHistoryAPI {
    var tradeModels: [ExchangeTradeCellModel] { get set }
    var canPage: Bool { get set }
    
    func hasExecutedTrades() -> Single<Bool>
    func getHomebrewTrades(before date: Date, completion: @escaping CompletionHandler)
    func getAllTrades(with completion: @escaping CompletionHandler)
    func isExecuting() -> Bool
    func cancel()
}

class ExchangeService: NSObject {
    
    /// Note: Don't use the `shared` instance unless absolutely necessary
    /// this is only being used in `CardsViewController+KYC` because
    /// `CardsViewController` is an ObjC class and extensions
    /// cannot have stored properties. 
    static let shared = ExchangeService()
    
    typealias CompletionHandler = ((Result<[ExchangeTradeCellModel], Error>) -> Void)

    var tradeModels: [ExchangeTradeCellModel] = []
    var canPage: Bool = false
    
    fileprivate let homebrewAPI: HomebrewExchangeAPI = HomebrewExchangeService()
    fileprivate var homebrewOperation: AsyncBlockOperation!
    fileprivate let tradeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    fileprivate func sort(models: [ExchangeTradeCellModel]) -> [ExchangeTradeCellModel] {
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
        
        if let op = homebrewOperation {
            guard op.isExecuting == false else { return }
        }
        
        var result: Result<[ExchangeTradeCellModel], Error> = .failure(NSError())
        homebrewOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.homebrewAPI.nextPage(fromTimestamp: date, completion: { payload in
                result = payload
                switch result {
                case .success(let value):
                    this.canPage = value.count >= 50
                    this.tradeModels.append(contentsOf: value)
                case .failure:
                    this.canPage = false
                }
                complete()
            })
        })
        homebrewOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            if case let .success(value) = result {
                let models = this.sort(models: value)
                completion(.success(models))
            } else {
                completion(result)
            }
        }
        homebrewOperation.start()
    }
    
    func getAllTrades(with completion: @escaping CompletionHandler) {
        /// Trades are being fetched, bail early.
        guard isExecuting() == false else { return }
        tradeModels = []
        
        homebrewOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.homebrewAPI.nextPage(fromTimestamp: Date(), completion: { result in
                switch result {
                case .success(let value):
                    this.canPage = value.count >= 50
                    this.tradeModels.append(contentsOf: value)
                case .failure(let error):
                    this.canPage = false
                    completion(.failure(error))
                }
                complete()
            })
        })
        homebrewOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            this.tradeModels = this.sort(models: this.tradeModels)
            completion(.success(this.tradeModels))
        }
        
        tradeQueue.addOperations([homebrewOperation], waitUntilFinished: false)
    }
    
    func isExecuting() -> Bool {
        guard let homebrew = homebrewOperation else { return false }
        return tradeQueue.operations.count > 0 || homebrew.isExecuting
    }
    
    func cancel() {
        tradeQueue.operations.forEach({$0.cancel()})
    }
}
