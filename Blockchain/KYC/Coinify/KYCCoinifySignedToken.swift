//
//  KYCCoinifySignedToken.swift
//  Blockchain
//
//  Created by AlexM on 4/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCCoinifySignedToken: Decodable {
    let success: Bool
    let token: String
    let error: String?
}
