//
//  HistoricalTransactionAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// `HistoricalTransactionAPI` is used for fetching transactions that the user has already submitted.
/// It returns a `[<HistoricalTransaction>]`. Depending on what asset type you are requesting
/// the page size may vary.
public protocol HistoricalTransactionAPI {
        
    associatedtype Model: HistoricalTransaction
    
    /// Fetches the transactions from local cache (Possible remote if the service deems it necessary).
    /// Element is Expected to be sorted by date in a descending chronological order
    var transactions: Single<[Model]> { get }
    
    /// Streams the latest transaction
    var latestTransaction: Single<Model?> { get }
    
    /// Fetches the transactions from remote.
    /// Element is Expected to be sorted by date in a descending chronological order
    func fetchTransactions() -> Single<[Model]>
    
    /// Streams a boolean indicating whether a certain transaction has been processed already
    func hasTransactionBeenProcessed(transactionHash: String) -> Single<Bool>
    
    /// Streams a boolean indicating whether there are transactions in the account
    var hasTransactions: Single<Bool> { get }
}

/// `HistoricalTransactionAPI` is used for fetching transactions that the user has already submitted.
/// It returns a `PageResult<HistoricalTransaction & Tokenized>`. Depending on what asset type you are requesting
/// the page size may vary. 
public protocol TokenizedHistoricalTransactionAPI {
    
    typealias AccountID = String
    
    associatedtype Model: HistoricalTransaction & Tokenized
    
    func fetchTransactions(token: String?, size: Int) -> Single<PageResult<Model>>
}
