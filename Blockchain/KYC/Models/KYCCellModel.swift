//
//  KYCCellModel.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum KYCCellModel {
    
    typealias Action = (() -> Void)
    
    case tier(TierCellModel)
    
    /// TODO: Include approval status
    public struct TierCellModel {
        let tier: KYCTier
        let action: Action
    }
}
