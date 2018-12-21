//
//  KYCTiersFooterView.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit
import PlatformUIKit

class KYCTiersFooterView: UICollectionReusableView {
    
    static let identifier: String = String(describing: KYCTiersFooterView.self)
    
    fileprivate static let verticalPadding: CGFloat = 32.0
    fileprivate static let horizontalPadding: CGFloat = 24.0
    
    // MARK: IBOutlets
    
    @IBOutlet fileprivate var disclaimerLabel: UILabel!
    
    // MARK: Public Functions
    
    func configure(with disclaimer: String) {
        disclaimerLabel.text = disclaimer
    }
    
    // MARK: Public Class Functions
    
    class func estimatedHeight(for disclaimer: String, width: CGFloat) -> CGFloat {
        let adjustedWidth = width - (horizontalPadding * 2)
        let height = NSAttributedString(
            string: disclaimer,
            attributes: [.font: disclaimerFont()]).heightForWidth(width: adjustedWidth)
        return height + verticalPadding
    }
    
    // MARK: Private Class Functions
    
    fileprivate class func disclaimerFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(12.0))
        return font.result
    }
    
}
