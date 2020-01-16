//
//  ExchangeAddressFetchingTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 23/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import Blockchain

class ExchangeAddressFetchingTests: XCTestCase {
    
    func testFetchingAddressForAllAssetsForActiveState() {
        for asset in AssetType.all {
            let fetcher = MockExchangeAddressFetcher(expectedResult: .success(.active))
            do {
                _ = try fetcher.fetchAddress(for: asset).toBlocking().first()
            } catch {
                XCTFail("expected success, got \(error) instead")
            }
        }
    }
    
    func testFetchingAddressForAllAssetsForInactiveState() {
        for asset in AssetType.all {
            for state in [ExchangeAddressFetcher.AddressResponseBody.State.pending,
                          ExchangeAddressFetcher.AddressResponseBody.State.blocked] {
                            let fetcher = MockExchangeAddressFetcher(expectedResult: .success(state))
                            do {
                                _ = try fetcher.fetchAddress(for: asset).toBlocking().first()
                                XCTFail("expected failure for \(state) account state, got success instead")
                            } catch { // Failure is a success
                                XCTAssert(true)
                            }
            }
        }
    }
}
