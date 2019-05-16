//
//  PairingCodeQRCodeParser.swift
//  Blockchain
//
//  Created by Jack on 17/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

final class PairingCodeQRCodeParser: QRCodeScannerParsing {
    
    enum PairingCodeParsingError: Error {
        case scannerError(QRScannerError)
        case invalidPairingCode
        case stringError
        case decryptionError
        case unknown
    }
    
    struct PairingCode {
        let passcodePayload: PasscodePayload
    }
    
    private let walletManager: WalletManager
    private let loadingViewPresenter: LoadingViewPresenter
    
    init(walletManager: WalletManager = WalletManager.sharedInstance(), loadingViewPresenter: LoadingViewPresenter = LoadingViewPresenter.shared) {
        self.walletManager = walletManager
        self.loadingViewPresenter = loadingViewPresenter
    }
    
    func parse(scanResult: NewResult<String, QRScannerError>, completion: ((NewResult<PairingCode, PairingCodeParsingError>) -> Void)?) {
        switch scanResult {
        case .success(let pairingCode):
            handleSuccess(pairingCode: pairingCode, completion: completion)
        case .failure(let error):
            completion?(.failure(.scannerError(error)))
        }
    }
    
    private func handleSuccess(pairingCode: String, completion: ((NewResult<PairingCode, PairingCodeParsingError>) -> Void)?) {
        walletManager.wallet.loadBlankWallet()
        walletManager.wallet.parsePairingCode(pairingCode, success: { [weak self] pairingCodeDict in
            self?.didParsePairingCode(pairingCodeDict, completion: completion)
        }, error: { [weak self] errorMessage in
            self?.errorParsingPairingCode(errorMessage, completion: completion)
        })
    }
    
    private func didParsePairingCode(_ dict: [AnyHashable : Any]!, completion: ((NewResult<PairingCode, PairingCodeParsingError>) -> Void)?) {
        walletManager.wallet.didPairAutomatically = true
        completion?(.success(PairingCodeQRCodeParser.PairingCode(passcodePayload: PasscodePayload(dictionary: dict))))
    }
    
    private func errorParsingPairingCode(_ message: String!, completion: ((NewResult<PairingCode, PairingCodeParsingError>) -> Void)?) {
        loadingViewPresenter.hideBusyView()
        
        switch message {
        case "Invalid Pairing Version Code":
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.invalidPairingCode))
        case "TypeError: must start with number", "TypeError: First argument must be a string":
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.stringError))
        case "Decryption Error":
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.decryptionError))
        default:
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.unknown))
        }
    }
}
