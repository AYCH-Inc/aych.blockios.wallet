//
//  NabuCreateUserResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct NabuCreateUserResponse: Decodable {
    let userId: String
    let token: String
}
