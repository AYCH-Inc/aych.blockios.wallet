//
//  PairingCodeQRCodeParser.swift
//  Blockchain
//
//  Created by Jack on 17/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

final class PairingCodeQRCodeParser: QRCodeScannerParsing {
    
    // MARK: - Types
    
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
    
    // MARK: - Setup
    
    init(walletManager: WalletManager = .shared) {
        self.walletManager = walletManager
    }
    
    func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<PairingCode, PairingCodeParsingError>) -> Void)?) {
        switch scanResult {
        case .success(let pairingCode):
            handleSuccess(pairingCode: pairingCode, completion: completion)
        case .failure(let error):
            completion?(.failure(.scannerError(error)))
        }
    }
    
    private func handleSuccess(pairingCode: String, completion: ((Result<PairingCode, PairingCodeParsingError>) -> Void)?) {
        walletManager.wallet.parsePairingCode(pairingCode, success: { [weak self] pairingCodeDict in
            self?.didParsePairingCode(pairingCodeDict, completion: completion)
        }, error: { [weak self] errorMessage in
            self?.errorParsingPairingCode(errorMessage, completion: completion)
        })
    }
    
    private func didParsePairingCode(_ dict: [AnyHashable : Any]!, completion: ((Result<PairingCode, PairingCodeParsingError>) -> Void)?) {
        completion?(.success(PairingCodeQRCodeParser.PairingCode(passcodePayload: PasscodePayload(dictionary: dict))))
    }
    
    private func errorParsingPairingCode(_ message: String!, completion: ((Result<PairingCode, PairingCodeParsingError>) -> Void)?) {
        guard let message = message else {
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.unknown))
            return
        }
        if message.contains("Invalid Pairing Version Code") {
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.invalidPairingCode))
        } else if message.contains("TypeError: must start with number") ||
            message.contains("TypeError: First argument must be a string") {
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.stringError))
        } else if message.contains("Decryption Error") {
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.decryptionError))
        } else {
            completion?(.failure(PairingCodeQRCodeParser.PairingCodeParsingError.unknown))
        }
    }
}
