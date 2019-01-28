//
//  NabuUser.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct NabuUser: Decodable {

    enum UserState: String {
        case none = "NONE"
        case created = "CREATED"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    let personalDetails: PersonalDetails?
    let address: UserAddress?
    let email: Email
    let mobile: Mobile?
    let status: KYCAccountStatus
    let state: UserState
    let tiers: NabuUserTiers?
    let tags: Tags?
    let needsDocumentResubmission: DocumentResubmission?

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case status = "kycState"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case emailVerified = "emailVerified"
        case mobileVerified = "mobileVerified"
        case mobile = "mobile"
        case identifier = "id"
        case state = "state"
        case tags = "tags"
        case tiers = "tiers"
        case needsDocumentResubmission = "resubmission"
    }

    init(
        personalDetails: PersonalDetails?,
        address: UserAddress?,
        email: Email,
        mobile: Mobile?,
        status: KYCAccountStatus,
        state: UserState,
        tags: Tags?,
        tiers: NabuUserTiers?,
        needsDocumentResubmission: DocumentResubmission?
    ) {
        self.personalDetails = personalDetails
        self.address = address
        self.email = email
        self.mobile = mobile
        self.status = status
        self.state = state
        self.tags = tags
        self.tiers = tiers
        self.needsDocumentResubmission = needsDocumentResubmission
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let userID = try values.decodeIfPresent(String.self, forKey: .identifier)
        let firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        let lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        let emailAddress = try values.decode(String.self, forKey: .email)
        let emailVerified = try values.decode(Bool.self, forKey: .emailVerified)
        let phoneNumber = try values.decodeIfPresent(String.self, forKey: .mobile)
        let phoneVerified = try values.decodeIfPresent(Bool.self, forKey: .mobileVerified)
        let statusValue = try values.decode(String.self, forKey: .status)
        let userState = try values.decode(String.self, forKey: .state)
        address = try values.decodeIfPresent(UserAddress.self, forKey: .address)
        tiers = try values.decodeIfPresent(NabuUserTiers.self, forKey: .tiers)

        personalDetails = PersonalDetails(
            id: userID,
            first: firstName,
            last: lastName,
            birthday: nil
        )

        email = Email(address: emailAddress, verified: emailVerified)
        
        if let number = phoneNumber {
            mobile = Mobile(
                phone: number,
                verified: phoneVerified ?? false
            )
        } else {
            mobile = nil
        }

        status = KYCAccountStatus(rawValue: statusValue) ?? .none
        state = UserState(rawValue: userState) ?? .none
        tags = try values.decodeIfPresent(Tags.self, forKey: .tags)
        needsDocumentResubmission = try values.decodeIfPresent(DocumentResubmission.self, forKey: .needsDocumentResubmission)
    }
}

struct Email: Decodable {
    let address: String
    let verified: Bool

    enum CodingKeys: String, CodingKey {
        case address = "email"
        case verified = "emailVerified"
    }
}

struct Mobile: Decodable {
    let phone: String
    let verified: Bool

    enum CodingKeys: String, CodingKey {
        case phone = "mobile"
        case verified = "mobileVerified"
    }
}

struct Tags: Decodable {
    let sunriver: Sunriver?

    enum CodingKeys: String, CodingKey {
        case sunriver = "SUNRIVER"
    }
}

struct Sunriver: Decodable {
    let campaignAddress: String

    enum CodingKeys: String, CodingKey {
        case campaignAddress = "x-campaign-address"
    }
}

struct DocumentResubmission: Decodable {
    let reason: Int

    enum CodingKeys: String, CodingKey {
        case reason
    }
}
