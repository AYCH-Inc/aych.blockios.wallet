//
//  KYCSettingsAPI.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol KYCSettingsAPI {
    var isCompletingKyc: Bool { get set }

    var latestKycPage: KYCPageType? { get set }

    func reset()
}
