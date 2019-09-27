//
//  AnnouncementType.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// The announcement types as defined remotely
enum AnnouncementType: String, Codable {
    case walletIntro = "wallet_intro"
    case verifyEmail = "verify_email"
    case buyBitcoin = "buy_btc"
    case transferBitcoin = "transfer_btc"
    case pitLinking = "pit_linking"
    case twoFA = "two_fa"
    case backupFunds = "backup_funds"
    case verifyIdentity = "kyc_incomplete"
    case swap = "swap"
    case pax = "pax"
    case bitpay = "bitpay"
    case coinifyKyc = "kyc_more_info"
    case resubmitDocuments = "kyc_resubmit"
    
    /// The key indentifying the announcement in cache
    var key: AnnouncementRecord.Key {
        switch self {
        case .walletIntro:
            return .walletIntro
        case .verifyEmail:
            return .verifyEmail
        case .buyBitcoin:
            return .buyBitcoin
        case .transferBitcoin:
            return .transferBitcoin
        case .pitLinking:
            return .pit
        case .twoFA:
            return .twoFA
        case .backupFunds:
            return .backupFunds
        case .verifyIdentity:
            return .identityVerification
        case .swap:
            return .swap
        case .pax:
            return .pax
        case .bitpay:
            return .bitpay
        case .coinifyKyc:
            return .coinifyKyc
        case .resubmitDocuments:
            return .resubmitDocuments
        }
    }
    
    /// Returns the analytics event that corresponds for Self value
    func event(name: AnalyticsEvents.Announcement.Name) -> AnalyticsEvents.Announcement {
        return .init(name: name, type: self)
    }
}
