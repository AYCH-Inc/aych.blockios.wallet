//
//  QRCodeScannerViewController.swift
//  Blockchain
//
//  Created by Jack on 15/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import ToolKit
import PlatformKit
import PlatformUIKit

enum QRCodePresentationType {
    case modal(dismissWithAnimation: Bool)
    case child
}

final class QRCodeScannerViewController: UIViewController {
    
    private var viewFrame: CGRect {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Trying to get key window before it was set!")
        }
        let width = window.bounds.size.width
        let height = window.bounds.size.height - Constants.Measurements.DefaultHeaderHeight
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    private var scannerView: QRCodeScannerView!
    
    private let viewModel: QRCodeScannerViewModelProtocol
    private let loadingViewStyle: LoadingViewPresenter.LoadingViewStyle
    private let loadingViewPresenter: LoadingViewPresenting
    private let presentationType: QRCodePresentationType
    
    init(presentationType: QRCodePresentationType = .modal(dismissWithAnimation: true),
         viewModel: QRCodeScannerViewModelProtocol,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         loadingViewStyle: LoadingViewPresenter.LoadingViewStyle = .activityIndicator) {
        self.presentationType = presentationType
        self.viewModel = viewModel
        self.loadingViewPresenter = loadingViewPresenter
        self.loadingViewStyle = loadingViewStyle
        super.init(nibName: nil, bundle: nil)
        switch presentationType {
        case .modal(dismissWithAnimation: let animated):
            modalTransitionStyle = .crossDissolve
            self.viewModel.closeButtonTapped = { [weak self] in
                self?.dismiss(animated: animated)
            }
        case .child:
            break
        }
        
        self.viewModel.scanningStarted = { [weak self] in
            self?.scanDidStart()
            Logger.shared.info("Scanning started")
        }
        
        self.viewModel.scanningStopped = { [weak self] in
            self?.scanDidStop()
        }
        
        self.viewModel.scanComplete = { [weak self] result in
            self?.handleScanComplete(with: result)
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch presentationType {
        case .modal:
            title = viewModel.headerText
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: #imageLiteral(resourceName: "close"),
                style: .plain,
                target: self,
                action: #selector(closeButtonClicked)
            )
        case .child:
            break
        }

        scannerView = QRCodeScannerView(viewModel: viewModel, frame: viewFrame)
        scannerView.alpha = 0
        view.addSubview(scannerView)
        scannerView.fillSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startReadingQRCode()
        scannerView?.startReadingQRCode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
    }
    
    @objc func closeButtonClicked(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }
    
    private func handleScanComplete(with result: Result<String, QRScannerError>) {
        if let loadingText = viewModel.loadingText {
            switch loadingViewStyle {
            case .activityIndicator:
                loadingViewPresenter.show(with: loadingText)
            case .circle:
                loadingViewPresenter.showCircular(with: loadingText)
            }
            
        }
        switch presentationType {
        case .modal(dismissWithAnimation: let animated):
            dismiss(animated: animated) { [weak self] in
                self?.viewModel.handleDismissCompleted(with: result)
            }
        case .child:
            viewModel.handleDismissCompleted(with: result)
        }
    }
    
    private func scanDidStart() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseIn, .transitionCrossDissolve, .beginFromCurrentState],
            animations: {
                self.scannerView?.alpha = 1
            },
            completion: nil
        )
    }
    
    private func scanDidStop() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseIn, .transitionCrossDissolve, .beginFromCurrentState],
            animations: {
                self.scannerView?.alpha = 0
            },
            completion: { _ in
                self.scannerView?.removePreviewLayer()
            }
        )
    }
}
