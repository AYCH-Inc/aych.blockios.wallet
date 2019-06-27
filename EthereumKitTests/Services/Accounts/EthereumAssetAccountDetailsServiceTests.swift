//
//  EthereumAssetAccountDetailsServiceTests.swift
//  EthereumKitTests
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import PlatformKit
@testable import EthereumKit

class EthereumAssetAccountDetailsServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: EthereumWalletBridgeMock!
    var ethereumAPIClient: EthereumAPIClientMock!
    var subject: EthereumAssetAccountDetailsService!
    
    override func setUp() {
        super.setUp()
        
        ethereumAPIClient = EthereumAPIClientMock()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        bridge = EthereumWalletBridgeMock()
        subject = EthereumAssetAccountDetailsService(
            with: bridge,
            client: ethereumAPIClient
        )
    }

    override func tearDown() {
        
        bridge = nil
        subject = nil
        
        super.tearDown()
    }

    func test_get_account_details() {
        // Arrange
        let accountID = ""
        let account = EthereumAssetAccountDetails.Account(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: "My Ether Wallet"
        )
        let balance = CryptoValue.etherFromMajor(decimal: Decimal(2.0))
        let expectedAccountDetails = EthereumAssetAccountDetails(
            account: account,
            balance: balance
        )
        
        let sendObservable: Observable<EthereumAssetAccountDetails> = subject
            .accountDetails(for: accountID)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumAssetAccountDetails> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumAssetAccountDetails>>] = Recorded.events(
            .next(
                200,
                expectedAccountDetails
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
}
