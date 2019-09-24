//
//  UnspentOutputRepositoryTests.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import BitcoinKit

class UnspentOutputRepositoryTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: BitcoinWalletBridgeMock!
    var client: APIClientMock!
    var subject: UnspentOutputRepository!

    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        bridge = BitcoinWalletBridgeMock()
        client = APIClientMock()
        subject = UnspentOutputRepository(with: bridge, client: client)
    }

    override func tearDown() {
        
        scheduler = nil
        disposeBag = nil
        
        subject = nil
        client = nil
        bridge = nil
        
        super.tearDown()
    }

    func test_fetch_unspent_outputs() {
        
        let expectedUnspents = UnspentOutputs(outputs: [])
        
        client.unspentOutputsValue = Single.just(UnspentOutputsResponse(unspent_outputs: []))
        
        // Arrange
        let unspentOutputsObservable = subject
            .fetchUnspentOutputs
            .asObservable()

        // Act
        let result: TestableObserver<UnspentOutputs> = scheduler
            .start { unspentOutputsObservable }

        // Assert
        let expectedEvents: [Recorded<Event<UnspentOutputs>>] = Recorded.events(
            .next(
                200,
                expectedUnspents
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
