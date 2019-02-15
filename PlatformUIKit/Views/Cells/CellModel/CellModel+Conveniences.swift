//
//  CellModel+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension CellModel {
    func cellType() -> BaseCell.Type {
        switch self {
        case .transactionDetail:
            return TransactionDetailCell.self
        case .pricePreview:
            return PricePreviewCell.self
        }
    }
    
    func reuseIdentifier() -> String {
        switch self {
        case .transactionDetail:
            return TransactionDetailCell.identifier
        case .pricePreview:
            return PricePreviewCell.identifier
        }
    }
    
    func heightForProposed(width: CGFloat) -> CGFloat {
        return cellType().heightForProposedWidth(width, model: self)
    }
}
