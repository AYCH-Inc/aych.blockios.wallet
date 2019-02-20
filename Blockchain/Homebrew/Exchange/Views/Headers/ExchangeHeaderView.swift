//
//  ExchangeHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/13/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeHeaderView: UICollectionReusableView {
    
    static var identifier: String { return String(describing: self) }
    
    func configure(with model: ExchangeHeader) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    /// Subclasses should override this function to determine the height
    /// of the header view.
    class func heightForProposedWidth(_ width: CGFloat, model: ExchangeHeader) -> CGFloat {
        return 0.0
    }
}
