//
//  KYCCell.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCCell: UICollectionViewCell {
    
    func configure(with model: KYCCellModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    class func heightForProposedWidth(_ width: CGFloat, model: KYCCellModel) -> CGFloat {
        // Cells should override this method.
        return 0.0
    }
    
    // MARK: - Accessibility
    
    /// Implements initial cell accessibility property values.
    internal func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.none
        shouldGroupAccessibilityChildren = false
    }
}
