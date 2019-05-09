//
//  KYCCoinifySignupPayload.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCCoinifySignupPayload: Encodable {
    let trustedEmailValidationToken: String
    let email: String
    let defaultCurrency: String
    let partnerId: Int
    let profile: KYCCoinifyProfile
}

struct KYCCoinifyProfile: Encodable {
    let address: KYCCoinifyAddress
    
    init(countryCode: String) {
        address = KYCCoinifyAddress(country: countryCode)
    }
}

struct KYCCoinifyAddress: Encodable {
    let country: String
}
