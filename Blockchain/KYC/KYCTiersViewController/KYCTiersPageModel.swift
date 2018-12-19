//
//  KYCTiersPageModel.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

struct KYCTiersPageModel {
    let header: KYCTiersHeaderViewModel
    let cells: [KYCTierCellModel]
}

extension KYCTiersPageModel {
    var disclaimer: String? {
        guard let tierOne = cells.filter({ $0.tier == .tier1 }).first else { return nil }
        guard let tierTwo = cells.filter({ $0.tier == .tier2 }).first else { return nil }
        guard tierTwo.status != .rejected else { return nil }
        if tierOne.status == .none && tierTwo.status == .none {
            return LocalizationConstants.KYC.completingTierTwoEligibility
        } else {
            return LocalizationConstants.KYC.completingTierTwoAutoEligible
        }
    }
}
