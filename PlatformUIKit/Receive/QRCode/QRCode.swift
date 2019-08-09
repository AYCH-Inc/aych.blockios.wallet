//
//  QRCode.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import UIKit

public protocol QRCodeAPI {
    var image: UIImage? { get }
}

/// Generated a `QRCode` by passing in `CryptoAssetQRMetadata` and then
/// accessing the `.image` property.
public struct QRCode: QRCodeAPI {
    
    private let data: Data
    
    public init?(metadata: CryptoAssetQRMetadata) {
        // TODO:
        // * Decide what to do about this (address vs url)
        // * Add tests
        self.init(string: metadata.address)
    }
    
    public init?(string: String) {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        self.init(data: data)
    }
    
    public init(data: Data) {
        self.data = data
    }
    
    public var image: UIImage? {
        guard let coreImage = ciImage else { return nil }
        return coreImage.nonInterpolatedImage(with: UIScreen.main.scale)
    }
    
    private var ciImage: CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        return filter.outputImage
    }
}

extension CIImage {
    fileprivate func nonInterpolatedImage(with scale: CGFloat) -> UIImage? {
        guard let image: CGImage = CIContext(options: nil).createCGImage(self, from: extent) else { return nil }
        let size = CGSize(width: extent.size.width * scale, height: extent.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(image, in: context.boundingBoxOfClipPath)
        guard let result: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
