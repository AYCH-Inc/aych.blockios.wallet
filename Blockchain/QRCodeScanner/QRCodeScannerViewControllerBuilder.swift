//
//  QRCodeScannerViewControllerBuilder.swift
//  Blockchain
//
//  Created by Jack on 18/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

final class QRCodeScannerViewControllerBuilder<P: QRCodeScannerParsing> {
    
    private struct Dependencies<P: QRCodeScannerParsing> {
        let parser: P
        let textViewModel: QRCodeScannerTextViewModel
        let completed: CompletionHandler
    }
    
    private enum SetupType<P: QRCodeScannerParsing> {
        case viewModel(QRCodeScannerViewModel<P>)
        case dependencies(Dependencies<P>)
    }
    
    typealias CompletionHandler = ((NewResult<P.T, P.U>) -> Void)
    
    private var scanner: QRCodeScanner? = QRCodeScanner()
    private var loadingViewPresenter: LoadingViewPresenter = LoadingViewPresenter.shared
    private var dismissAnimated: Bool = true
    
    private let setupType: SetupType<P>
    
    init(parser: P, textViewModel: QRCodeScannerTextViewModel, completed: @escaping CompletionHandler) {
        self.setupType = .dependencies(
            Dependencies(
                parser: parser,
                textViewModel: textViewModel,
                completed: completed
            )
        )
    }
    
    init?(viewModel: QRCodeScannerViewModel<P>?) {
        guard let viewModel = viewModel else { return nil }
        self.setupType = .viewModel(viewModel)
    }
    
    func with(scanner: QRCodeScanner?) -> QRCodeScannerViewControllerBuilder {
        self.scanner = scanner
        return self
    }
    
    func with(loadingViewPresenter: LoadingViewPresenter) -> QRCodeScannerViewControllerBuilder {
        self.loadingViewPresenter = loadingViewPresenter
        return self
    }
    
    func with(dismissAnimated: Bool) -> QRCodeScannerViewControllerBuilder {
        self.dismissAnimated = dismissAnimated
        return self
    }
    
    func build() -> UIViewController? {
        switch setupType {
        case .dependencies(let dependencies):
            guard let scanner = scanner else { return nil }
            
            let vm = QRCodeScannerViewModel<P>(
                parser: dependencies.parser,
                textViewModel: dependencies.textViewModel,
                scanner: scanner,
                completed: dependencies.completed
            )
    
            guard let qrCodeScannerViewModel = vm else { return nil }
            
            let scannerViewController = QRCodeScannerViewController(
                viewModel: qrCodeScannerViewModel,
                loadingViewPresenter: loadingViewPresenter,
                dismissAnimated: dismissAnimated
            )
            return UINavigationController(rootViewController: scannerViewController)
        case .viewModel(let qrCodeScannerViewModel):
            let scannerViewController = QRCodeScannerViewController(
                viewModel: qrCodeScannerViewModel,
                loadingViewPresenter: loadingViewPresenter,
                dismissAnimated: dismissAnimated
            )
            return UINavigationController(rootViewController: scannerViewController)
        }
    }
}
