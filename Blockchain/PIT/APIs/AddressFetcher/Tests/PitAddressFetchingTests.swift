//
//  PitAddressFetchingTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 23/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import Blockchain

class PitAddressFetchingTests: XCTestCase {
    
    func testFetchingAddressForAllAssetsForActiveState() {
        for asset in AssetType.all {
            let fetcher = MockPitAddressFetcher(expectedResult: .success(.active))
            do {
                _ = try fetcher.fetchAddress(for: asset).toBlocking().first()
            } catch {
                XCTFail("expected success, got \(error) instead")
            }
        }
    }
    
    func testFetchingAddressForAllAssetsForInactiveState() {
        for asset in AssetType.all {
            for state in [PitAddressFetcher.PitAddressResponseBody.State.pending,
                          PitAddressFetcher.PitAddressResponseBody.State.blocked] {
                            let fetcher = MockPitAddressFetcher(expectedResult: .success(state))
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
