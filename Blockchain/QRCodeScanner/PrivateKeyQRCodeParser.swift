//
//  PrivateKeyQRCodeParser.swift
//  Blockchain
//
//  Created by Jack on 17/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

final class PrivateKeyQRCodeParser: QRCodeScannerParsing {
    
    enum PrivateKeyQRCodeParserError: Error {
        case scanError(QRScannerError)
        case unknownKeyFormat
        case unsupportedPrivateKey
        
        var privateKeyReaderError: PrivateKeyReaderError {
            switch self {
            case .scanError(_):
                return PrivateKeyReaderError.badMetadataObject
            case .unknownKeyFormat:
                return PrivateKeyReaderError.unknownKeyFormat
            case .unsupportedPrivateKey:
                return PrivateKeyReaderError.unsupportedPrivateKey
            }
        }
    }
    
    struct PrivateKey {
        let scannedKey: String
        let assetAddress: AssetAddress?
    }
    
    private let walletManager: WalletManager
    private let loadingViewPresenter: LoadingViewPresenter
    private let acceptPublicKeys: Bool
    private let assetAddress: AssetAddress?
    
    init(walletManager: WalletManager = WalletManager.shared, loadingViewPresenter: LoadingViewPresenter = LoadingViewPresenter.shared, acceptPublicKeys: Bool, assetAddress: AssetAddress?) {
        self.walletManager = walletManager
        self.loadingViewPresenter = loadingViewPresenter
        self.acceptPublicKeys = acceptPublicKeys
        self.assetAddress = assetAddress
    }
    
    func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<PrivateKey, PrivateKeyQRCodeParserError>) -> Void)?) {
        switch scanResult {
        case .success(let privateKey):
            handleSuccess(privateKey: privateKey, completion: completion)
        case .failure(let error):
            completion?(.failure(.scanError(error)))
        }
    }
    
    private func handleSuccess(privateKey stringValue: String, completion: ((Result<PrivateKey, PrivateKeyQRCodeParserError>) -> Void)?) {
        let scheme = "\(Constants.Schemes.bitcoin):"
        var scannedKey = stringValue
        //: strip scheme if applicable
        if stringValue.hasPrefix(scheme) {
            let startIndex = stringValue.index(stringValue.startIndex, offsetBy: scheme.count)
            let description = String(stringValue[startIndex...])
            scannedKey = description
        }
        //: Check if the scanned key is a private key, otherwise try public key if accepted
        guard let format = walletManager.wallet.detectPrivateKeyFormat(scannedKey), format.count > 0 else {
            loadingViewPresenter.hideBusyView()
            if acceptPublicKeys {
                let address = BitcoinAddress(string: scannedKey)
                let validator = AddressValidator(context: WalletManager.shared.wallet.context)
                guard validator.validate(bitcoinAddress: address) else {
                    completion?(.failure(.unknownKeyFormat))
                    return
                }
                walletManager.askUserToAddWatchOnlyAddress(address) { [weak self] in
                    completion?(.success(PrivateKey(scannedKey: scannedKey, assetAddress: self?.assetAddress)))
                }
            } else {
                completion?(.failure(.unsupportedPrivateKey))
            }
            return
        }
        //: Pass valid private key back via success handler
        completion?(.success(PrivateKey(scannedKey: scannedKey, assetAddress: assetAddress)))
    }
}
