//
//  StellarLedgerService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import StellarKit
import PlatformKit
import RxSwift
import RxCocoa

// TODO: This should be moved to `StellarKit`

class StellarLedgerService: StellarLedgerAPI {

    let fallbackBaseReserve: Decimal = 0.5
    let fallbackBaseFee: Decimal = CryptoValue.lumensFromStroops(int: StellarTransactionFee.defaultLimits.min).majorValue
    
    var current: Observable<StellarLedger> {
        return fetchLedgerStartingWithCache(
            cachedValue: privateLedger,
            networkValue: fetchLedger
        )
    }
    
    var currentLedger: StellarLedger? {
        return privateLedger.value
    }
    
    private var privateLedger = BehaviorRelay<StellarLedger?>(value: nil)
    
    private var fetchLedger: Single<StellarLedger> {
        return Single.zip(getLedgers, feeService.fees)
            .flatMap { value -> Single<StellarLedger> in
                let (ledger, fees) = value
                // Convert from Lumens to stroops
                guard let baseFeeInStroops: Int = try? StellarValue(value: fees.regular).stroops() else {
                    return Single.just(ledger.apply(baseFeeInStroops: StellarTransactionFee.defaultLimits.min))
                }
                return Single.just(ledger.apply(baseFeeInStroops: baseFeeInStroops))
            }
            .do(onSuccess: { [weak self] ledger in
                self?.privateLedger.accept(ledger)
            })
    }
    
    private var getLedgers: Single<StellarLedger> {
        return Single<StellarLedger>.create { observer -> Disposable in
            self.ledgersService.ledgers(cursor: nil, order: .descending, limit: 1) { result in
                switch result {
                case .success(let value):
                    if let input = value.allRecords.first {
                        let ledger = StellarLedger(
                            identifier: input.id,
                            token: input.pagingToken,
                            sequence: Int(input.sequenceNumber),
                            transactionCount: input.successfulTransactionCount,
                            operationCount: input.operationCount,
                            closedAt: input.closedAt,
                            totalCoins: input.totalCoins,
                            baseFeeInStroops: input.baseFeeInStroops,
                            baseReserveInStroops: input.baseReserveInStroops
                        )
                        observer(.success(ledger))
                    } else {
                        observer(.error(NSError() as Error))
                    }
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    private let ledgersService: LedgersServiceAPI
    private let feeService: StellarFeeServiceAPI
    
    init(ledgersService: LedgersServiceAPI, feeService: StellarFeeServiceAPI) {
        self.ledgersService = ledgersService
        self.feeService = feeService
    }
    
    convenience init(configuration: StellarConfiguration = .production, feeService: StellarFeeServiceAPI) {
        self.init(
            ledgersService: { configuration.sdk.ledgers }(),
            feeService: feeService
        )
    }
    
    private func fetchLedgerStartingWithCache(
        cachedValue: BehaviorRelay<StellarLedger?>,
        networkValue: Single<StellarLedger>
        ) -> Observable<StellarLedger> {
        let networkObservable = networkValue.asObservable()
        guard let cachedValue = cachedValue.value else {
            return networkObservable
        }
        return networkObservable.startWith(cachedValue)
    }
}
