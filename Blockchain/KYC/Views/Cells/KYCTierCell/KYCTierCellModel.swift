//
//  KYCTierCellModel.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct KYCTierCellModel {
    typealias Action = ((KYCTier) -> Void)
    
    let tier: KYCTier
    let action: Action
}

extension KYCTierCellModel {
    static let demo: KYCTierCellModel = KYCTierCellModel(
    tier: .tier1) { tier in
        print("")
    }
    static let demo2: KYCTierCellModel = KYCTierCellModel(
    tier: .tier2) { tier in
        print("")
    }
}
