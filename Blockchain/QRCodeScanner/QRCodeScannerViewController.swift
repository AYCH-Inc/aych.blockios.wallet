//
//  QRCodeScannerViewController.swift
//  Blockchain
//
//  Created by Jack on 15/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit

final class QRCodeScannerViewController: UIViewController {
    
    private var viewFrame: CGRect {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Trying to get key window before it was set!")
        }
        let width = window.bounds.size.width
        let height = window.bounds.size.height - Constants.Measurements.DefaultHeaderHeight
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    private var scannerView: QRCodeScannerView?
    
    private let viewModel: QRCodeScannerViewModelProtocol
    private let loadingViewPresenter: LoadingViewPresenter
    private let dismissAnimated: Bool
    
    init(viewModel: QRCodeScannerViewModelProtocol, loadingViewPresenter: LoadingViewPresenter = LoadingViewPresenter.shared, dismissAnimated: Bool = true) {
        self.viewModel = viewModel
        self.loadingViewPresenter = loadingViewPresenter
        self.dismissAnimated = dismissAnimated
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        
        self.viewModel.scanningStarted = {
            Logger.shared.info("Scanning started")
        }
        
        self.viewModel.scanningStopped = { [weak self] in
            self?.scannerView?.removePreviewLayer()
        }
        
        self.viewModel.closeButtonTapped = { [weak self] in
            self?.dismiss(animated: dismissAnimated)
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
        
        title = viewModel.headerText
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "close"),
            style: .plain,
            target: self,
            action: #selector(closeButtonClicked)
        )
        
        scannerView = QRCodeScannerView(viewModel: viewModel, frame: viewFrame)
        view.addSubview(scannerView!)
        
        scannerView!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scannerView!.topAnchor.constraint(equalTo: view.topAnchor),
            scannerView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.startReadingQRCode()
        scannerView?.startReadingQRCode()
    }
    
    @objc func closeButtonClicked(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }
    
    private func handleScanComplete(with result: Result<String, QRScannerError>) {
        if let loadingText = viewModel.loadingText {
            loadingViewPresenter.showBusyView(withLoadingText: loadingText)
        }
        dismiss(animated: dismissAnimated) { [weak self] in
            self?.viewModel.handleDismissCompleted(with: result)
        }
    }
}
