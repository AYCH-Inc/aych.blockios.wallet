//
//  EthereumWalletAccountRepositoryTests.swift
//  EthereumKitTests
//
//  Created by Jack on 05/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import PlatformKit
@testable import EthereumKit

class EthereumWalletAccountRepositoryTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: EthereumWalletBridgeMock!
    var ethereumDeriver: EthereumKeyPairDeriverMock!
    var deriver: AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>!
    var subject: EthereumWalletAccountRepository!

    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        bridge = EthereumWalletBridgeMock()
        ethereumDeriver = EthereumKeyPairDeriverMock()
        deriver = AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>(deriver: AnyEthereumKeyPairDeriver(with: ethereumDeriver))
        
        subject = EthereumWalletAccountRepository(
            with: bridge,
            deriver: deriver
        )
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        
        bridge = nil
        deriver = nil
        subject = nil
        
        super.tearDown()
    }

    func test_load_key_pair() {
        // Arrange
        let expectedKeyPair = MockEthereumWalletTestData.keyPair
        
        let sendObservable: Observable<EthereumKeyPair> = subject.loadKeyPair()
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumKeyPair> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumKeyPair>>] = Recorded.events(
            .next(
                200,
                expectedKeyPair
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
}
