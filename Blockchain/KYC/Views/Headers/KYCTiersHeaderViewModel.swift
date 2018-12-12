//
//  KYCTiersHeaderViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCTiersHeaderViewModel {
    
    enum Action {
        case learnMore
        case contactSupport
        case swapNow
    }
    
    let availableAmount: String?
    let headline: String
    let description: String
    let actions: [Action]?
    
    init(headline: String,
         description: String,
         availableAmount: String? = nil,
         actions: [Action]? = nil) {
        self.headline = headline
        self.description = description
        self.availableAmount = availableAmount
        self.actions = actions
    }
}

extension KYCTiersHeaderViewModel {
    // TODO: Only for testing purposes
    static let demo: KYCTiersHeaderViewModel = KYCTiersHeaderViewModel(
        headline: LocalizationConstants.KYC.swapTagline,
        description: LocalizationConstants.KYC.swapAnnouncement,
        availableAmount: nil,
        actions: nil
    )
}
