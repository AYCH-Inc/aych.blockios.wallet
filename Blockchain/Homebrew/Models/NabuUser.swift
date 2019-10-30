//
//  NabuUser.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol NabuUserSunriverAirdropRegistering {
    var isSunriverAirdropRegistered: Bool { get }
}

protocol NabuUserBlockstackAirdropRegistering {
    var isBlockstackAirdropRegistered: Bool { get }
}

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
    let pitUserName: String?
    let depositAddresses: [DepositAddress]?
    let settings: NabuUserSettings?
    
    /// ISO-8601 Timestamp w/millis, eg 2018-08-15T17:00:45.129Z
    let kycCreationDate: String?
       
    /// ISO-8601 Timestamp w/millis, eg 2018-08-15T17:00:45.129Z
    let kycUpdateDate: String?
    
    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case status = "kycState"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case dob
        case emailVerified = "emailVerified"
        case mobileVerified = "mobileVerified"
        case mobile = "mobile"
        case identifier = "id"
        case state = "state"
        case tags = "tags"
        case tiers = "tiers"
        case needsDocumentResubmission = "resubmission"
        case userName
        case walletAddresses
        case settings
        case kycCreationDate = "insertedAt"
        case kycUpdateDate = "updatedAt"
    }

    init(
        hasLinkedPITAccount: Bool = false,
        personalDetails: PersonalDetails?,
        address: UserAddress?,
        email: Email,
        mobile: Mobile?,
        status: KYCAccountStatus,
        state: UserState,
        tags: Tags?,
        tiers: NabuUserTiers?,
        needsDocumentResubmission: DocumentResubmission?,
        pitUserName: String? = nil,
        depositAddresses: [DepositAddress]? = nil,
        settings: NabuUserSettings? = nil,
        kycCreationDate: String? = nil,
        kycUpdateDate: String? = nil
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
        self.pitUserName = pitUserName
        self.depositAddresses = depositAddresses
        self.settings = settings
        self.kycCreationDate = kycCreationDate
        self.kycUpdateDate = kycUpdateDate
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
        let birthdayValue = try values.decodeIfPresent(String.self, forKey: .dob)
        pitUserName = try values.decodeIfPresent(String.self, forKey: .userName)
        settings = try values.decodeIfPresent(NabuUserSettings.self, forKey: .settings)
        let depositAddresses = try values.decodeIfPresent([String: String].self, forKey: .walletAddresses)
        
        if let addresses = depositAddresses {
            self.depositAddresses = addresses.compactMap { (key, value) -> DepositAddress? in
                return DepositAddress(stringValue: key, address: value)
            }
        } else {
            self.depositAddresses = nil
        }
        
        var birthday: Date?
        if let value = birthdayValue {
            birthday = DateFormatter.birthday.date(from: value)
        }
        personalDetails = PersonalDetails(
            id: userID,
            first: firstName,
            last: lastName,
            birthday: birthday
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
        
        kycCreationDate = try values.decodeIfPresent(String.self, forKey: .kycCreationDate)
        kycUpdateDate = try values.decodeIfPresent(String.self, forKey: .kycUpdateDate)
    }
    
    func swapApproved() -> Bool {
        guard let tiers = tiers else { return false }
        guard tiers.current != .tier0 else { return false }
        return true
    }
}

extension NabuUser {
    var hasLinkedPITAccount: Bool {
        return settings != nil
    }
}

extension NabuUser {
    var isGoldTierVerified: Bool {
        guard let tiers = tiers else { return false }
        return tiers.current == .tier2
    }
}

extension NabuUser: NabuUserSunriverAirdropRegistering {
    var isSunriverAirdropRegistered: Bool {
        return tags?.sunriver != nil
    }
}

extension NabuUser: NabuUserBlockstackAirdropRegistering {
    var isBlockstackAirdropRegistered: Bool {
        return tags?.blockstack != nil
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
    let blockstack: Blockstack?
    let coinify: Bool?
    let powerPax: PowerPax?
    
    enum CodingKeys: String, CodingKey {
        case sunriver = "SUNRIVER"
        case blockstack = "BLOCKSTACK"
        case coinify = "COINIFY"
        case powerPax = "POWER_PAX"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sunriver = try values.decodeIfPresent(Sunriver.self, forKey: .sunriver)
        blockstack = try values.decodeIfPresent(Blockstack.self, forKey: .blockstack)
        coinify = try values.decodeIfPresent(Bool.self, forKey: .coinify)
        powerPax = try values.decodeIfPresent(PowerPax.self, forKey: .powerPax)
    }
    
    init(sunriver: Sunriver? = nil, blockstack: Blockstack? = nil, coinify: Bool = false, powerPax: PowerPax? = nil) {
        self.sunriver = sunriver
        self.blockstack = blockstack
        self.coinify = coinify
        self.powerPax = powerPax
    }
}

struct Sunriver: Decodable {
    let campaignAddress: String

    enum CodingKeys: String, CodingKey {
        case campaignAddress = "x-campaign-address"
    }
}

struct Blockstack: Decodable {
    let campaignAddress: String

    enum CodingKeys: String, CodingKey {
        case campaignAddress = "x-campaign-address"
    }
}

struct PowerPax: Decodable {
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

struct DepositAddress {
    
    let type: AssetType
    let address: String
    
    init?(stringValue: String, address: String) {
        guard let type = AssetType(stringValue: stringValue) else { return nil }
        self.type = type
        self.address = address
    }
    
    init(type: AssetType, address: String) {
        self.type = type
        self.address = address
    }
}

struct NabuUserSettings: Decodable {
    let mercuryEmailVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case mercuryEmailVerified = "MERCURY_EMAIL_VERIFIED"
    }
}

extension DepositAddress {
    var dictionaryRepresentation: [String: String] {
        return [type.symbol: address]
    }
}
