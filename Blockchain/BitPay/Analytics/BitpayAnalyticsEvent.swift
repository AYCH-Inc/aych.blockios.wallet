//
//  BitpayAnalyticsEvent.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

enum BitpayAnalyticsEvent: AnalyticsEvent {
    case urlScanned(AssetType)
    case urlPasted(AssetType)
    case urlDeepLink(AssetType)
    case expired
    case success
    case failure(Error?)

    var name: String {
        switch self {
        case .urlDeepLink:
            return "bitpay_url_deeplink"
        case .urlScanned:
            return "bitpay_url_scanned"
        case .urlPasted:
            return "bitpay_url_pasted"
        case .expired:
            return "bitpay_payment_expired"
        case .success:
            return "bitpay_payment_success"
        case .failure:
            return "bitpay_payment_failure"
        }
    }

    var params: [String : String]? {
        switch self {
        case .urlDeepLink(let assetType),
             .urlScanned(let assetType),
             .urlPasted(let assetType):
            return ["currency": assetType.cryptoCurrency.rawValue]
        case .expired,
             .success:
            return nil
        case .failure(let error):
            guard let error = error else { return nil }
            return ["error": error.localizedDescription]
        }
    }
}

// MARK: - Deprecate these once we SendBitcoinViewController is written in Swift

@objc class BitpayUrlScanned: NSObject, ObjcAnalyticsEvent {
    private let legacyAssetType: LegacyAssetType

    private var event: AnalyticsEvent {
        let assetType = AssetTypeLegacyHelper.convert(fromLegacy: legacyAssetType)
        return BitpayAnalyticsEvent.urlScanned(assetType)
    }

    @objc class func create(legacyAssetType: LegacyAssetType) -> BitpayUrlScanned {
        return BitpayUrlScanned(legacyAssetType: legacyAssetType)
    }

    init(legacyAssetType: LegacyAssetType) {
        self.legacyAssetType = legacyAssetType
    }

    var name: String {
        return event.name
    }

    var params: [String : String]? {
        return event.params
    }
}

@objc class BitpayUrlPasted: NSObject, ObjcAnalyticsEvent {
    private let legacyAssetType: LegacyAssetType

    private var event: AnalyticsEvent {
        let assetType = AssetTypeLegacyHelper.convert(fromLegacy: legacyAssetType)
        return BitpayAnalyticsEvent.urlPasted(assetType)
    }

    @objc class func create(legacyAssetType: LegacyAssetType) -> BitpayUrlPasted {
        return BitpayUrlPasted(legacyAssetType: legacyAssetType)
    }

    init(legacyAssetType: LegacyAssetType) {
        self.legacyAssetType = legacyAssetType
    }

    var name: String {
        return event.name
    }

    var params: [String : String]? {
        return event.params
    }
}

@objc class BitpayPaymentExpired: NSObject, ObjcAnalyticsEvent {
    var name: String {
        return BitpayAnalyticsEvent.expired.name
    }

    var params: [String : String]? {
        return BitpayAnalyticsEvent.expired.params
    }
}
