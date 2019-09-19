//
//  AnnouncementRecord+Key.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

extension AnnouncementRecord {
    
    enum Key: String, CaseIterable {
        
        // MARK: - Persistent
        
        case walletIntro = "announcement-cache-wallet-intro"
        case verifyEmail = "announcement-cache-email-verification"
        
        // MARK: - Periodic
        
        case backupFunds = "announcement-cache-backup-funds"
        case twoFA = "announcement-cache-2fa"
        case buyBitcoin = "announcement-cache-buy-btc"
        case swap = "announcement-cache-swap"
        
        // MARK: - One Time
        
        case identityVerification = "announcement-cache-identity-verification"
        case pax = "announcement-cache-pax"
        case pit = "announcement-cache-pit"
        case bitpay = "announcement-cache-bitpay"
        case coinifyKyc = "announcement-cache-coinify-kyc"
        case resubmitDocuments = "announcement-cache-resubmit-documents"
    }
    
    @available(*, deprecated, message: "`LegacyKey` was superseded by `Key` and is not being used anymore.")
    enum LegacyKey: String {
        
        case shouldHidePITLinkingCard
        case hasSeenPAXCard
        
        var key: Key? {
            switch self {
            case .hasSeenPAXCard:
                return .pax
            case .shouldHidePITLinkingCard:
                return .pit
            }
        }
    }
}

