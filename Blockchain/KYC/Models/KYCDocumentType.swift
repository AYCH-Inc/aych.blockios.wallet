//
//  KYCDocumentType.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCDocumentType: String, CaseIterable, Codable {
    case passport = "PASSPORT"
    case driversLicense = "DRIVING_LICENCE"
    case nationalIdentityCard = "NATIONAL_IDENTITY_CARD"
    case residencePermit = "RESIDENCE_PERMIT"
}

extension KYCDocumentType {
    var description: String {
        switch self {
        case .passport:
            return LocalizationConstants.KYC.passport
        case .driversLicense:
            return LocalizationConstants.KYC.driversLicense
        case .nationalIdentityCard:
            return LocalizationConstants.KYC.nationalIdentityCard
        case .residencePermit:
            return LocalizationConstants.KYC.residencePermit
        }
    }
}
