//
//  QRCodeScannerViewModel.swift
//  Blockchain
//
//  Created by Jack on 15/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

protocol QRCodeScannerTextViewModel {
    var loadingText: String? { get }
    var headerText: String { get }
}

struct PrivateKeyQRCodeTextViewModel: QRCodeScannerTextViewModel {
    let loadingText: String?
    let headerText: String
    
    init(loadingText: String = LocalizationConstants.AddressAndKeyImport.loadingImportKey, headerText: String = LocalizationConstants.scanQRCode) {
        self.loadingText = loadingText
        self.headerText = headerText
    }
}

struct PairingCodeQRCodeTextViewModel: QRCodeScannerTextViewModel {
    let loadingText: String? = LocalizationConstants.parsingPairingCode
    let headerText: String = LocalizationConstants.scanPairingCode
}

struct AddressQRCodeTextViewModel: QRCodeScannerTextViewModel {
    let loadingText: String? = nil
    let headerText: String = LocalizationConstants.scanQRCode
}

protocol QRCodeScannerViewModelProtocol: class {
    var scanningStarted: (() -> Void)? { get set }
    var scanningStopped: (() -> Void)? { get set }
    var closeButtonTapped: (() -> Void)? { get set }
    var scanComplete: ((NewResult<String, QRScannerError>) -> Void)? { get set }
    
    var videoPreviewLayer: CALayer? { get }
    var loadingText: String? { get }
    var headerText: String { get }
    
    func closeButtonPressed()
    func startReadingQRCode()
    func handleDismissCompleted(with scanResult: NewResult<String, QRScannerError>)
}

final class QRCodeScannerViewModel<P: QRCodeScannerParsing>: QRCodeScannerViewModelProtocol {
    
    var scanningStarted: (() -> Void)?
    var scanningStopped: (() -> Void)?
    var closeButtonTapped: (() -> Void)?
    var scanComplete: ((NewResult<String, QRScannerError>) -> Void)?
    
    var videoPreviewLayer: CALayer? {
        return scanner.videoPreviewLayer
    }
    
    var loadingText: String? {
        return textViewModel.loadingText
    }
    
    var headerText: String {
        return textViewModel.headerText
    }
    
    private let parser: AnyQRCodeScannerParsing<P.T, P.U>
    private let textViewModel: QRCodeScannerTextViewModel
    private let scanner: QRCodeScannerProtocol
    private let completed: ((NewResult<P.T, P.U>) -> Void)
    
    init?(parser: P, textViewModel: QRCodeScannerTextViewModel, scanner: QRCodeScannerProtocol, completed: ((NewResult<P.T, P.U>) -> Void)?) {
        guard let completed = completed else { return nil }
        
        self.parser = AnyQRCodeScannerParsing(parser: parser)
        self.textViewModel = textViewModel
        self.scanner = scanner
        self.completed = completed
        self.scanner.delegate = self
    }
    
    func closeButtonPressed() {
        scanner.stopReadingQRCode(complete: nil)
        closeButtonTapped?()
    }
    
    func startReadingQRCode() {
        scanner.startReadingQRCode()
    }
    
    func handleDismissCompleted(with scanResult: NewResult<String, QRScannerError>) {
        parser.parse(scanResult: scanResult, completion: completed)
    }
}

extension QRCodeScannerViewModel: QRCodeScannerDelegate {
    func scanComplete(with result: NewResult<String, QRScannerError>) {
        scanComplete?(result)
    }
    
    func didStartScanning() {
        scanningStarted?()
    }
    
    func didStopScanning() {
        scanningStopped?()
    }
}
