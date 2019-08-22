//
//  SendFeeService.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import RxSwift
import RxRelay
import BigInt

protocol SendFeeServicing: class {
    
    /// An observable that streams the fee
    var fee: Observable<CryptoValue> { get }

    /// A trigger to (re-)fetch the fee. Handy for any refresh scenario
    var triggerRelay: PublishRelay<Void> { get }
}

final class SendFeeService: SendFeeServicing {
    
    // MARK: - Exposed Properties

    // TODO: Failure retry logic

    var fee: Observable<CryptoValue> {
        let fee: Observable<CryptoValue>
        switch asset {
        case .ethereum:
            fee = etherFee
        case .bitcoin, .bitcoinCash, .pax, .stellar:
            fatalError("\(#function) does not support \(asset.description)")
        }
        return Observable
            .combineLatest(fee, triggerRelay)
            .map { $0.0 }
    }
    
    let triggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private var etherFee: Observable<CryptoValue> {
        return ethereumService.fees
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { fee -> CryptoValue in
                let gasPrice = BigUInt(fee.priority.amount)
                let gasLimit = BigUInt(fee.gasLimitContract)
                let cost = gasPrice * gasLimit
                if let value = CryptoValue.etherFromWei(string: "\(cost)") {
                    return value
                } else {
                    throw SendCalculationState.CalculationError.valueCouldNotBeCalculated
                }
            }
            .asObservable()
    }
    
    // MARK: - Injected
    
    private let asset: AssetType
    private let ethereumService: EthereumFeeServiceAPI
    
    // MARK: - Setup
    
    init(asset: AssetType,
         ethereumService: EthereumFeeServiceAPI = EthereumFeeService.shared) {
        self.asset = asset
        self.ethereumService = ethereumService
    }    
}
