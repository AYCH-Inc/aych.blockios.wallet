//
//  BlockstackServiceTests.swift
//  BlockchainTests
//
//  Created by Jack on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import PlatformKit
@testable import BitcoinKit
@testable import PlatformUIKit
@testable import Blockchain

class BlockstackServiceTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var dataRepository: MockBlockchainDataRepository!
    var airdropRegistration: AirdropRegistrationMock!
    var nabuAuthenticationService: NabuAuthenticationServiceMock!
    var blockStackAccountRepository: BlockstackAccountRepositoryMock!
    var kycSettings: KYCSettingsMock!
    
    var subject: BlockstackService!

    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        dataRepository = MockBlockchainDataRepository()
        airdropRegistration = AirdropRegistrationMock()
        nabuAuthenticationService = NabuAuthenticationServiceMock()
        blockStackAccountRepository = BlockstackAccountRepositoryMock()
        kycSettings = KYCSettingsMock()
        
        subject = BlockstackService(
            dataRepository: dataRepository,
            airdropRegistration: airdropRegistration,
            nabuAuthenticationService: nabuAuthenticationService,
            blockStackAccountRepository: blockStackAccountRepository,
            kycSettings: kycSettings
        )
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func test_register_for_airdrop() {
        // Arrange
        dataRepository.mockNabuUser = NabuUser(
            hasLinkedExchangeAccount: false,
            personalDetails: PersonalDetails(
                id: "id",
                first: "first",
                last: "last",
                birthday: Date(
                    timeIntervalSince1970: TimeInterval(0)
                )
            ),
            address: nil,
            email: Email(
                address: "name@example.com",
                verified: true
            ),
            mobile: nil,
            status: KYCAccountStatus.approved,
            state: .active,
            tags: Tags(
                sunriver: nil,
                blockstack: nil,
                coinify: false,
                powerPax: nil
            ),
            tiers: .init(
                current: .tier2,
                selected: .tier2,
                next: .tier2
            ),
            needsDocumentResubmission: nil,
            userName: nil,
            depositAddresses: [],
            settings: nil
        )
        
        let registerObservable: Observable<Never> = subject
            .registerForCampaignIfNeeded
            .asObservable()

        // Act
        let result: TestableObserver<Never> = scheduler
            .start { registerObservable }

        // Assert
        let expectedEvents: [Recorded<Event<Never>>] = Recorded.events(
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
