//
//  EthereumWalletServiceTests.swift
//  EthereumKitTests
//
//  Created by Jack on 10/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import BigInt
import web3swift
import PlatformKit
@testable import EthereumKit

class EthereumWalletServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: EthereumWalletBridgeMock!
    var ethereumAPIClient: EthereumAPIClientMock!
    var feeService: EthereumFeeServiceMock!
    
    var transactionBuilder: EthereumTransactionBuilder!
    var transactionSigner: EthereumTransactionSignerAPI!
    var transactionEncoder: EthereumTransactionEncoder!
    
    var walletAccountRepository: EthereumWalletAccountRepositoryMock!
    
    var transactionCreationService: EthereumTransactionCreationService!
    
    var subject: EthereumWalletService!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        bridge = EthereumWalletBridgeMock()
        ethereumAPIClient = EthereumAPIClientMock()
        feeService = EthereumFeeServiceMock()
        
        transactionBuilder = EthereumTransactionBuilder.shared
        transactionSigner = EthereumTransactionSigner.shared
        transactionEncoder = EthereumTransactionEncoder.shared
        
        walletAccountRepository = EthereumWalletAccountRepositoryMock()
        
        transactionCreationService = EthereumTransactionCreationService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            transactionBuilder: transactionBuilder,
            transactionSigner: transactionSigner,
            transactionEncoder: transactionEncoder
        )
        
        subject = EthereumWalletService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            walletAccountRepository: walletAccountRepository,
            transactionCreationService: transactionCreationService
        )
    }
    
    override func tearDown() {
        
        scheduler = nil
        disposeBag = nil
        
        bridge = nil
        ethereumAPIClient = nil
        feeService = nil
        
        transactionBuilder = nil
        transactionSigner = nil
        transactionEncoder = nil
        
        walletAccountRepository = nil
        
        transactionCreationService = nil
        
        subject = nil
        
        super.tearDown()
    }
    
    func test_send_successfully() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder().build()!
        let expectedFinalised = EthereumTransactionFinalisedBuilder().build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!

        bridge.recordLastTransactionValue = Single.just(expectedPublished)
        ethereumAPIClient.pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: expectedPublished.transactionHash))
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .next(
                200,
                expectedPublished
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
        XCTAssertNotNil(bridge.lastRecordedTransaction)
        guard let lastRecordedTransaction = bridge.lastRecordedTransaction else {
            XCTFail("Failed to record transaction")
            return
        }
        XCTAssertEqual(lastRecordedTransaction, expectedPublished)
        
        XCTAssertNotNil(ethereumAPIClient.lastPushedTransaction)
        guard let lastPushedTransaction = ethereumAPIClient.lastPushedTransaction else {
            XCTFail("Should have successfully pushed the finalised transaction")
            return
        }
        XCTAssertEqual(lastPushedTransaction, expectedFinalised)
    }
    
    func test_send_transaction_pending() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder().build()!
        
        bridge.isWaitingOnEtherTransactionValue = Single.just(true)
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumWalletServiceError.waitingOnPendingTransaction)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_sending_amount_over_balance() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(amount: Decimal(1.0))
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!
        
        bridge.balanceValue = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(0.1)))
        bridge.recordLastTransactionValue = Single.just(expectedPublished)
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumTransactionBuilderError.insufficientFunds)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_sending_fees_over_balance() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(amount: Decimal(0.01))
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!
        
        let l = TransactionFeeLimits(
            min: 100,
            max: 1_100
        )
        let f = EthereumTransactionFee(
            limits: l,
            regular: 1_000,
            priority: 1_000,
            gasLimit: 21_000
        )
        feeService.feesValue = Single.just(f)
        bridge.balanceValue = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(0.02)))
        bridge.recordLastTransactionValue = Single.just(expectedPublished)
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumTransactionBuilderError.insufficientFunds)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_signing_error() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(amount: Decimal(0.01))
            .build()!
        let expectedCandidateCosted = EthereumTransactionCandidateCostedBuilder().build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!
        
        let transactionSignerMock = EthereumTransactionSignerMock()
        transactionSigner = transactionSignerMock
        
        transactionCreationService = EthereumTransactionCreationService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            transactionBuilder: transactionBuilder,
            transactionSigner: transactionSigner,
            transactionEncoder: transactionEncoder
        )
        
        subject = EthereumWalletService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            walletAccountRepository: walletAccountRepository,
            transactionCreationService: transactionCreationService
        )
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumTransactionSignerError.incorrectChainId)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
        
        XCTAssertNotNil(transactionSignerMock.lastKeyPair)
        XCTAssertNotNil(transactionSignerMock.lastTransactionForSignature)
        
        guard let lastKeyPair = transactionSignerMock.lastKeyPair else {
            XCTFail("Should have attempted to sign using the correct keyPair")
            return
        }
        XCTAssertEqual(lastKeyPair, MockEthereumWalletTestData.keyPair)
        
        guard let lastTransactionForSignature = transactionSignerMock.lastTransactionForSignature else {
            XCTFail("Should have attempted to sign using the correct transaction")
            return
        }
        XCTAssertEqual(lastTransactionForSignature, expectedCandidateCosted)
    }
    
    func test_failed_to_publish_transaction() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(amount: Decimal(1.0))
            .build()!
        
        ethereumAPIClient.pushTransactionValue = Single.error(EthereumAPIClientMockError.mockError)
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumAPIClientMockError.mockError)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_failed_to_record_transaction() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(amount: Decimal(1.0))
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!
        
        ethereumAPIClient.pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: expectedPublished.transactionHash))
        bridge.recordLastTransactionValue = Single.error(EthereumWalletBridgeMockError.mockError)

        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumWalletBridgeMockError.mockError)
        )

        XCTAssertEqual(result.events, expectedEvents)
        XCTAssertEqual(bridge.lastRecordedTransaction, expectedPublished)
    }
    
    func test_failed_to_fetch_balance() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(amount: Decimal(1.0))
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!

        ethereumAPIClient.pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: expectedPublished.transactionHash))
        bridge.balanceValue = Single.error(EthereumWalletBridgeMockError.mockError)
        bridge.recordLastTransactionValue = Single.just(expectedPublished)

        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumWalletBridgeMockError.mockError)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}

extension EthereumTransactionPublished: Equatable {
    public static func == (lhs: EthereumTransactionPublished, rhs: EthereumTransactionPublished) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
    }
}

extension EthereumTransactionFinalised: Equatable {
    public static func == (lhs: EthereumTransactionFinalised, rhs: EthereumTransactionFinalised) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
            && lhs.rawTx == rhs.rawTx
    }
}

extension EthereumTransactionCandidateCosted: Equatable {
    public static func == (lhs: EthereumTransactionCandidateCosted, rhs: EthereumTransactionCandidateCosted) -> Bool {
        return lhs.transaction.gasLimit == rhs.transaction.gasLimit
            && lhs.transaction.gasPrice == rhs.transaction.gasPrice
    }
}
