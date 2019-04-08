//
//  StellarLedgerServiceTests.swift
//  BlockchainTests
//
//  Created by Jack on 02/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxBlocking
import RxSwift
import stellarsdk
import StellarKit
@testable import Blockchain

class LedgerResponseMock: LedgerResponseProtocol {
    var id: String = ""
    var pagingToken: String = ""
    var sequenceNumber: Int64 = 0
    var successfulTransactionCount: Int?
    var operationCount: Int = 0
    var closedAt: Date = Date()
    var totalCoins: String = ""
    var baseFeeInStroops: Int?
    var baseReserveInStroops: Int?
}

class LedgerPageResponseMock: PageResponseProtocol {
    var allRecords: [LedgerResponseProtocol] {
        return _allRecords
    }
    
    var _allRecords: [LedgerResponseMock] = [
        LedgerResponseMock()
    ]
}

class LedgersServiceMock: LedgersServiceAPI {
    var result: NewResult<PageResponseProtocol, StellarLedgerServiceError> = NewResult.success(LedgerPageResponseMock())
    func ledgers(cursor: String?, order: stellarsdk.Order?, limit: Int?, response: @escaping (NewResult<PageResponseProtocol, StellarLedgerServiceError>) -> Void) {
        response(result)
    }
}

class StellarFeeServiceMock: StellarFeeServiceAPI {
    static let fee = StellarTransactionFee(limits: StellarTransactionFee.defaultLimits, regular: 1000, priority: 10000)
    var stellarFees: Single<StellarTransactionFee> = Single.just(StellarFeeServiceMock.fee)
    var fees: Single<StellarTransactionFee> {
        return stellarFees
    }
}

class StellarLedgerServiceTests: XCTestCase {
    
    var subject: StellarLedgerService!
    var ledgersService: LedgersServiceMock!
    var feeService: StellarFeeServiceMock!
    var disposables = CompositeDisposable()
    
    override func setUp() {
        super.setUp()
        
        disposables = CompositeDisposable()
        feeService = StellarFeeServiceMock()
        ledgersService = LedgersServiceMock()
        subject = StellarLedgerService(
            ledgersService: ledgersService,
            feeService: feeService
        )
    }
    
    override func tearDown() {
        disposables.dispose()
        feeService = nil
        ledgersService = nil
        subject = nil
        
        super.tearDown()
    }
    
    func test_returns_correct_fee() {
        let feeIsCorrectExpectation = self.expectation(
            description: "The fee returned by the ledger should be the fee returned by the fee service"
        )
        
        let disposable = subject.current
            .subscribe(onNext: { ledger in
                XCTAssertEqual(ledger.baseFeeInStroops, 1000)
                feeIsCorrectExpectation.fulfill()
            }, onError: { error in
                XCTFail("this shouldn't error")
            })
        _ = disposables.insert(disposable)
        
        waitForExpectations(timeout: TimeInterval(5))
    }
}
