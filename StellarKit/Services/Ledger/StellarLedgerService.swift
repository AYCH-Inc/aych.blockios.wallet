//
//  StellarLedgerService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import PlatformKit
import RxSwift
import RxCocoa

// TODO: This should be moved to `StellarKit`

public class StellarLedgerService: StellarLedgerAPI {

    public let fallbackBaseReserve: Decimal = 0.5
    public let fallbackBaseFee: Decimal = CryptoValue.lumensFromStroops(int: StellarTransactionFee.defaultLimits.min).majorValue
    
    public var current: Observable<StellarLedger> {
        return fetchLedgerStartingWithCache(
            cachedValue: privateLedger,
            networkValue: fetchLedger
        )
    }
    
    public var currentLedger: StellarLedger? {
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
        return ledgersService.flatMap(weak: self) { (self, ledgersService) -> Single<StellarLedger> in
            return Single<StellarLedger>.create { observer -> Disposable in
                ledgersService.ledgers(cursor: nil, order: .descending, limit: 1) { result in
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
    }
    
    private var ledgersService: Single<LedgersServiceAPI> {
        guard let ledgersService = ledgersServiceValue else {
            return sdk.map { $0.ledgers }
        }
        return Single.just(ledgersService)
    }

    private var sdk: Single<stellarsdk.StellarSDK> {
        return configuration.map { $0.sdk }
    }
    
    private var configuration: Single<StellarConfiguration> {
        return configurationService.configuration
    }
    
    private let configurationService: StellarConfigurationAPI
    private let feeService: StellarFeeServiceAPI
    private let ledgersServiceValue: LedgersServiceAPI?
    
    public init(
        configurationService: StellarConfigurationAPI = StellarConfigurationService.shared,
        ledgersService: LedgersServiceAPI? = nil,
        feeService: StellarFeeServiceAPI = StellarFeeService.shared) {
        self.ledgersServiceValue = ledgersService
        self.configurationService = configurationService
        self.feeService = feeService
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
