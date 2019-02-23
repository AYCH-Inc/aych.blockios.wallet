//
//  PairingCodeQRCodeParser.swift
//  Blockchain
//
//  Created by Jack on 17/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class PairingCodeQRCodeParserDelegate: NSObject, WalletDelegate {
    
    private let walletManager: WalletManager
    private let walletDelegate: WalletDelegate
    private let loadingViewPresenter: LoadingViewPresenter
    private let completion: ((NewResult<PairingCodeQRCodeParser.PairingCode, PairingCodeQRCodeParser.PairingCodeParsingError>) -> Void)?
    
    init(walletManager: WalletManager = WalletManager.shared, loadingViewPresenter: LoadingViewPresenter = LoadingViewPresenter.shared, completion: ((NewResult<PairingCodeQRCodeParser.PairingCode, PairingCodeQRCodeParser.PairingCodeParsingError>) -> Void)?) {
        self.walletManager = walletManager
        self.walletDelegate = walletManager.wallet.delegate
        self.loadingViewPresenter = loadingViewPresenter
        self.completion = completion
    }
    
    func didParsePairingCode(_ dict: [AnyHashable : Any]!) {
        walletManager.wallet.didPairAutomatically = true
        walletManager.wallet.delegate = walletDelegate
        completion?(.success(PairingCodeQRCodeParser.PairingCode(passcodePayload: PasscodePayload(dictionary: dict))))
    }
    
    func errorParsingPairingCode(_ message: String!) {
        walletManager.wallet.delegate = walletDelegate
        
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
        // A strong reference? why?
        // This is dangerous - if the delegate is overwritten this method will never complete
        walletManager.wallet.delegate = PairingCodeQRCodeParserDelegate(
            walletManager: walletManager,
            loadingViewPresenter: loadingViewPresenter,
            completion: completion
        )
        walletManager.wallet.parsePairingCode(pairingCode)
    }
}
