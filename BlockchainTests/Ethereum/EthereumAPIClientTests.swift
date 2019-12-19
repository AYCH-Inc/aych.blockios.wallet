//
//  EthereumAPIClientTests.swift
//  BlockchainTests
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import web3swift
@testable import NetworkKit
@testable import PlatformKit
@testable import EthereumKit
@testable import Blockchain

class EthereumAPIClientTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    var communicator: MockNetworkCommunicator!
    var networkConfig: NetworkKit.Network.Config!
    var subject: EthereumKit.APIClient!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        communicator = MockNetworkCommunicator()
        networkConfig = NetworkKit.Network.Config.defaultConfig

        subject = EthereumKit.APIClient(
            communicator: communicator,
            config: networkConfig
        )
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil

        subject = nil

        super.tearDown()
    }

    func test_push_transaction() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder().build()!
        let transaction = EthereumTransactionFinalisedBuilder()
            .with(candidate: candidate)
            .build()!
        let expectedResponse: EthereumKit.EthereumPushTxResponse
            = EthereumPushTxResponse(txHash: transaction.transactionHash)
        
        communicator.perfomRequestResponseFixture = "push_tx_response"

        let pushObservable: Observable<EthereumKit.EthereumPushTxResponse> = subject
            .push(transaction: transaction)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumKit.EthereumPushTxResponse> = scheduler
            .start { pushObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumKit.EthereumPushTxResponse>>] = Recorded.events(
            .next(
                200,
                expectedResponse
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
