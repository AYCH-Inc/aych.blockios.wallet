//
//  EthereumAccountAddressTests.swift
//  EthereumKitTests
//
//  Created by Jack on 21/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import EthereumKit

class EthereumAccountAddressTests: XCTestCase {
    
    func test_address_validation_fails_for_truncated_address() {
        
        var address = MockEthereumWalletTestData.account
        address.removeLast()
        
        let truncatedAddress = address
        
        let truncated = EthereumAccountAddress(rawValue: truncatedAddress)
        XCTAssertNil(truncated)
        
        do {
            try EthereumAccountAddress(string: truncatedAddress)
        } catch {
            guard let e = error as? EthereumKit.AddressValidationError else {
                XCTFail()
                return
            }
            XCTAssertEqual(e, EthereumKit.AddressValidationError.invalidLength)
            return
        }
    }
    
    func test_address_validation_fails_for_invalid_characters_in_address() {
        
        let invalidAddress = MockEthereumWalletTestData.account
            .replacingOccurrences(of: "e", with: "😈")
        
        let invalid = EthereumAccountAddress(rawValue: invalidAddress)
        XCTAssertNil(invalid)
        
        do {
            try EthereumAccountAddress(string: invalidAddress)
        } catch {
            guard let e = error as? EthereumKit.AddressValidationError else {
                XCTFail()
                return
            }
            XCTAssertEqual(e, EthereumKit.AddressValidationError.containsInvalidCharacters)
            return
        }
    }

}
