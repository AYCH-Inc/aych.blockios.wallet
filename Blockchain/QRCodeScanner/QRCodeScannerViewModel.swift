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
    var scanComplete: ((Result<String, QRScannerError>) -> Void)? { get set }
    
    var videoPreviewLayer: CALayer? { get }
    var loadingText: String? { get }
    var headerText: String { get }
    
    func closeButtonPressed()
    func startReadingQRCode()
    func handleDismissCompleted(with scanResult: Result<String, QRScannerError>)
    
    func viewWillDisappear()
}

final class QRCodeScannerViewModel<P: QRCodeScannerParsing>: QRCodeScannerViewModelProtocol {
    
    enum ParsingOptions {
        
        /// Strict approach, only act on the link using the given parser
        case strict
        
        /// Lax parsing, allow acting on other routes at well
        case lax(routes: [DeepLinkRoute])
    }
    
    var scanningStarted: (() -> Void)?
    var scanningStopped: (() -> Void)?
    var closeButtonTapped: (() -> Void)?
    var scanComplete: ((Result<String, QRScannerError>) -> Void)?
    
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
    private let completed: ((Result<P.T, P.U>) -> Void)
    private let deepLinkQRCodeRouter: DeepLinkQRCodeRouter
    
    init?(parser: P,
          additionalParsingOptions: ParsingOptions = .strict,
          textViewModel: QRCodeScannerTextViewModel,
          scanner: QRCodeScannerProtocol,
          completed: ((Result<P.T, P.U>) -> Void)?) {
        guard let completed = completed else { return nil }
        
        let additionalLinkRoutes: [DeepLinkRoute]
        switch additionalParsingOptions {
        case .lax(routes: let routes):
            additionalLinkRoutes = routes
        case .strict:
            additionalLinkRoutes = []
        }
        self.deepLinkQRCodeRouter = DeepLinkQRCodeRouter(supportedRoutes: additionalLinkRoutes)
        self.parser = AnyQRCodeScannerParsing(parser: parser)
        self.textViewModel = textViewModel
        self.scanner = scanner
        self.completed = completed
        self.scanner.delegate = self
    }
    
    func viewWillDisappear() {
        scanner.stopReadingQRCode(complete: nil)
    }
    
    func closeButtonPressed() {
        scanner.stopReadingQRCode(complete: nil)
        closeButtonTapped?()
    }
    
    func startReadingQRCode() {
        scanner.startReadingQRCode()
    }
    
    func handleDismissCompleted(with scanResult: Result<String, QRScannerError>) {
        
        // In case the designate scan purpose was not fulfilled, try look for supported deeplink.
        let completion = { [weak self] (result: Result<P.T, P.U>) in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.deepLinkQRCodeRouter.routeIfNeeded(using: scanResult)
            case .success:
                self.completed(result)
            }
        }
        parser.parse(scanResult: scanResult, completion: completion)
    }
}

extension QRCodeScannerViewModel: QRCodeScannerDelegate {
    func scanComplete(with result: Result<String, QRScannerError>) {
        scanComplete?(result)
    }
    
    func didStartScanning() {
        scanningStarted?()
    }
    
    func didStopScanning() {
        scanningStopped?()
    }
}
