//
//  QRCodeGenerator.swift
//  Blockchain
//
//  Created by Jack on 02/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BitcoinKit
import PlatformKit
import PlatformUIKit

@available(*, deprecated, message: "Don't use this, this is superseded by CryptoAssetQRMetadata")
@objc protocol QRCodeGeneratorAPI {
    func qrImage(fromAddress address: String, amount: String?, asset legacyAsset: LegacyAssetType, includeScheme: Bool) -> UIImage?
    func createQRImage(fromString string: String) -> UIImage?
}

@available(*, deprecated, message: "Don't use this, this is superseded by CryptoAssetQRMetadata")
@objc class QRCodeGenerator: NSObject, QRCodeGeneratorAPI {
    
    private let qrCodeWrapper: QRCodeWrapperAPI
    
    @objc override init() {
        self.qrCodeWrapper = QRCodeWrapper()
    }
    
    init(qrCodeWrapper: QRCodeWrapperAPI) {
        self.qrCodeWrapper = qrCodeWrapper
        super.init()
    }
    
    @objc func qrImage(fromAddress address: String, amount: String?, asset legacyAsset: LegacyAssetType, includeScheme: Bool) -> UIImage? {
        guard let metadata = metadata(address: address, amount: amount, asset: legacyAsset, includeScheme: includeScheme) else { return nil }
        let qr = qrCodeWrapper.qrCode(from: metadata)
        return qr?.image
    }
    
    @objc func createQRImage(fromString string: String) -> UIImage? {
        let qr = qrCodeWrapper.qrCode(from: string)
        return qr?.image
    }
    
    private func metadata(address: String, amount: String?, asset legacyAsset: LegacyAssetType, includeScheme: Bool) -> CryptoAssetQRMetadata? {
        switch legacyAsset {
        case .bitcoin:
            let metadata = BitcoinQRMetadata(
                address: address,
                amount: amount,
                includeScheme: includeScheme
            )
            return metadata
        case .bitcoinCash:
            let metadata = BitcoinCashURLPayload(
                address: address,
                amount: amount,
                includeScheme: includeScheme
            )
            return metadata
        default:
            return nil
        }
    }
}

public protocol QRCodeWrapperAPI {
    func qrCode(from metadata: CryptoAssetQRMetadata) -> QRCodeAPI?
    func qrCode(from string: String) -> QRCodeAPI?
}

class QRCodeWrapper: QRCodeWrapperAPI {
    func qrCode(from metadata: CryptoAssetQRMetadata) -> QRCodeAPI? {
        return QRCode(metadata: metadata)
    }
    
    func qrCode(from string: String) -> QRCodeAPI? {
        return QRCode(string: string)
    }
}
