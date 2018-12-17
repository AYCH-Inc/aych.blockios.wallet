//
//  KYCTierPostBody.swift
//  Blockchain
//
//  Created by kevinwu on 12/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct KYCTierPostBody: Codable {
    let selectedTier: KYCTier

    private enum CodingKeys: CodingKey {
        case selectedTier
    }
}
