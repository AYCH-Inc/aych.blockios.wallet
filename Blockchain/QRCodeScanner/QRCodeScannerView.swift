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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoPreviewLayer?.frame = bounds
    }
    
    func startReadingQRCode() {
        guard let videoPreviewLayer = viewModel.videoPreviewLayer else { return }
        
        videoPreviewLayer.frame = frame
        layer.addSublayer(videoPreviewLayer)
        
        self.videoPreviewLayer = videoPreviewLayer
    }
    
    func removePreviewLayer() {
        videoPreviewLayer?.removeFromSuperlayer()
    }
}
