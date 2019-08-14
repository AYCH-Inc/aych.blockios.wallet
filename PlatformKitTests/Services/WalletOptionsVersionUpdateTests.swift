//
//  WalletOptionsVersionUpdateTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 05/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class WalletOptionsVersionUpdateTests: XCTestCase {
    
    func testNoUpdate() {
        let expectedRawValue = WalletOptions.UpdateType.RawValue.none
        let updateType = generateUpdateType(from: expectedRawValue, version: "")
        guard case .none = updateType else {
            XCTFail("Expected \(expectedRawValue), got \(updateType.rawValue)")
            return
        }
    }
    
    func testMissingUpdateTypeFailure() {
        let updateType = generateUpdateType(from: "", version: "")
        guard case .none = updateType else {
            XCTFail("Expected \(WalletOptions.UpdateType.RawValue.none), got \(updateType.rawValue)")
            return
        }
    }
    
    func testUpdateTypeRecommendedWhileLatestVersionMissing() {
        let updateType = generateUpdateType(from: WalletOptions.UpdateType.RawValue.recommended, version: "")
        guard case .none = updateType else {
            XCTFail("Expected \(WalletOptions.UpdateType.RawValue.none), got \(updateType.rawValue)")
            return
        }
    }
    
    func testUpdateTypeForcedWhileLatestVersionMissing() {
        let updateType = generateUpdateType(from: WalletOptions.UpdateType.RawValue.forced, version: "")
        guard case .none = updateType else {
            XCTFail("Expected \(WalletOptions.UpdateType.RawValue.none), got \(updateType.rawValue)")
            return
        }
    }
    
    func testUpdateTypeRecommendedWithLatestVersion() {
        let expectedUpdateType = WalletOptions.UpdateType.RawValue.recommended
        let expectedAppVersionRawValue = "1.2.3"
        let expectedAppVersion = AppVersion(string: expectedAppVersionRawValue)!
        
        let updateType = generateUpdateType(from: expectedUpdateType, version: expectedAppVersionRawValue)
        
        switch updateType {
        case .recommended(latestVersion: let version) where version == expectedAppVersion:
            break
        default:
            XCTFail("Expected \(expectedUpdateType) with version \(expectedAppVersion), got \(updateType)")
        }
    }
    
    // MARK: - Private
    
    private func generateUpdateType(from updateTypeRawValue: String, version: String) -> WalletOptions.UpdateType {
        let json = [
            WalletOptions.Keys.ios: [
                WalletOptions.Keys.update:
                    [WalletOptions.Keys.updateType: updateTypeRawValue,
                     WalletOptions.Keys.latestStoreVersion: version
                ]
            ]
        ]
        let options = WalletOptions(json: json)
        return options.updateType
    }
}
