//
//  QRCodeScannerView.swift
//  Blockchain
//
//  Created by Jack on 15/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class QRCodeScannerView: UIView {
        
    private var videoPreviewLayer: CALayer?
    private let viewModel: QRCodeScannerViewModelProtocol
    
    init(viewModel: QRCodeScannerViewModelProtocol, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startReadingQRCode() {
        guard let videoPreviewLayer = viewModel.videoPreviewLayer else { return }
        
        let previewFrame = CGRect(x: frame.origin.x, y: Constants.Measurements.DefaultHeaderHeight, width: frame.width, height: frame.height)
        videoPreviewLayer.frame = previewFrame
        layer.addSublayer(videoPreviewLayer)
        
        self.videoPreviewLayer = videoPreviewLayer
    }
    
    func removePreviewLayer() {
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    @objc func closeButtonClicked(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }
    
    private func setup() {
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: Constants.Measurements.DefaultHeaderHeight))
        topBar.backgroundColor = .brandPrimary
        addSubview(topBar)
        
        let headerLabel = UILabel(frame: CGRect(x: 60, y: 26, width: 200, height: 30))
        headerLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraExtraLarge)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.text = viewModel.headerText //
        headerLabel.center = CGPoint(x: topBar.center.x, y: headerLabel.center.y)
        topBar.addSubview(headerLabel)
        
        let closeButton = UIButton(frame: CGRect(x: frame.size.width - 80, y: 15, width: 80, height: 51))
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 18)
        closeButton.contentHorizontalAlignment = .right
        closeButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        closeButton.center = CGPoint(x: closeButton.center.x, y: headerLabel.center.y)
        closeButton.addTarget(self, action: #selector(closeButtonClicked(sender:)), for: .touchUpInside)
        topBar.addSubview(closeButton)
    }
}
