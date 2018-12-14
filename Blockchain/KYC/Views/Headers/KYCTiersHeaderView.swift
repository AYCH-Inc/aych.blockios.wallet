//
//  KYCTiersHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit
import PlatformUIKit

protocol KYCTiersHeaderViewDelegate: class {
    func headerView(_ view: KYCTiersHeaderView, actionTapped: KYCTiersHeaderViewModel.Action)
    func dismissButtonTapped(_ view: KYCTiersHeaderView)
}

/// `KYCTiersHeaderView` is not supposed to be used directly. Use `KYCTiersHeaderViewModel`
/// to derive which header you're supposed to use. The reason we have multiple headers is the
/// designs were substantially different in terms of sizing and fonts.
class KYCTiersHeaderView: UICollectionReusableView {
    
    // MARK: Public
    
    weak var delegate: KYCTiersHeaderViewDelegate?
    
    // MARK: Public Functions
    
    func configure(with viewModel: KYCTiersHeaderViewModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    // MARK: Public Class Functions
    
    class func estimatedHeight(for width: CGFloat, model: KYCTiersHeaderViewModel) -> CGFloat {
        assertionFailure("Should be implemented by subclasses")
        return 0.0
    }
}
