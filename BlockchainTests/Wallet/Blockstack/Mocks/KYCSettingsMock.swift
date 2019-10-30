//
//  KYCSettingsMock.swift
//  BlockchainTests
//
//  Created by Jack on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCSettingsMock: KYCSettingsAPI {
    
    var isCompletingKyc: Bool = false
    
    var latestKycPage: KYCPageType?
    
    func reset() {
        fatalError("Not yet implemented")
    }
    
}
