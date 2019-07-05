//
//  StellarTransactionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit

protocol StellarTransactionAPI {
    
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountID = String

    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Completable
    func get(transaction transactionHash: String, completion: @escaping ((Result<StellarTransactionResponse, Error>) -> Void))
}
