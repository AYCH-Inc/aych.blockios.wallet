//
//  BlockstackAddressDeriverTests.swift
//  BitcoinKitTests
//
//  Created by Jack on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import TestKit
import HDWalletKit
@testable import BitcoinKit

class BlockstackAddressDeriverTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var subject: BlockstackAddressDeriver!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        subject = BlockstackAddressDeriver()
    }

    override func tearDown() {
        subject = nil
        scheduler = nil
        disposeBag = nil

        super.tearDown()
    }
    
    func test_derive() throws {
        // Arrange
        let expectedAddress = BlockstackAddress(rawValue: "1EpGdGDjLgxVWU925a81R2aApsKgvFKPXD")!
        let password = MockWalletTestData.password
        let mnemonic =  MockWalletTestData.mnemonic
        
        let deriveAddressObservable = subject
            .deriveAddress(mnemonic: mnemonic, password: password)
            .single
            .asObservable()

        // Act
        let result: TestableObserver<BlockstackAddress> = scheduler
            .start { deriveAddressObservable }

        // Assert
        let expectedEvents: [Recorded<Event<BlockstackAddress>>] = Recorded.events(
            .next(
                200,
                expectedAddress
            ),
            .completed(200)
        )
        XCTAssertEqual(result.events, expectedEvents)
    }

}

extension BlockstackAddress: Equatable {}
