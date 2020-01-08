//
//  QRCodeScannerViewControllerBuilder.swift
//  Blockchain
//
//  Created by Jack on 18/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

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
    
    typealias CompletionHandler = ((Result<P.T, P.U>) -> Void)
    
    private var scanner: QRCodeScanner? = QRCodeScanner()
    private var loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared
    private var loadingViewStyle: LoadingViewPresenter.LoadingViewStyle = .activityIndicator
    private var presentationType = QRCodePresentationType.modal(dismissWithAnimation: true)
    
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
    
    func with(loadingViewPresenter: LoadingViewPresenting,
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator) -> QRCodeScannerViewControllerBuilder {
        self.loadingViewStyle = style
        self.loadingViewPresenter = loadingViewPresenter
        return self
    }
    
    func with(presentationType: QRCodePresentationType) -> QRCodeScannerViewControllerBuilder {
        self.presentationType = presentationType
        return self
    }
    
    func build() -> UIViewController? {
        var scannerViewController: QRCodeScannerViewController?
        switch setupType {
        case .dependencies(let dependencies):
            guard let scanner = scanner else { return nil }
            
            let vm = QRCodeScannerViewModel<P>(
                parser: dependencies.parser,
                additionalParsingOptions: .lax(routes: [.exchangeLinking]),
                textViewModel: dependencies.textViewModel,
                scanner: scanner,
                completed: dependencies.completed
            )
    
            guard let qrCodeScannerViewModel = vm else { return nil }
            
            scannerViewController = QRCodeScannerViewController(
                presentationType: presentationType,
                viewModel: qrCodeScannerViewModel,
                loadingViewPresenter: loadingViewPresenter,
                loadingViewStyle: loadingViewStyle
            )
        case .viewModel(let qrCodeScannerViewModel):
            scannerViewController = QRCodeScannerViewController(
                presentationType: presentationType,
                viewModel: qrCodeScannerViewModel,
                loadingViewPresenter: loadingViewPresenter,
                loadingViewStyle: loadingViewStyle
            )
        }
        guard let scannerVC = scannerViewController else {
            return nil
        }
        switch presentationType {
        case .modal:
            let viewController = UINavigationController(rootViewController: scannerVC)
            viewController.modalPresentationStyle = .fullScreen
            return viewController
        case .child:
            return scannerVC
        }
    }
}
