//
//  CellModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum CellModel: Equatable {
    case transactionDetail(TransactionDetail)
    case pricePreview(PricePreview)
}

public extension CellModel {
    func configure(_ cell: BaseCell) {
        cell.configure(self)
    }
}

public extension CellModel {
    public static func ==(lhs: CellModel, rhs: CellModel) -> Bool {
        switch (lhs, rhs) {
        case (.transactionDetail(let left), .transactionDetail(let right)):
            return left == right
        case (.pricePreview(let left), .pricePreview(let right)):
            return left == right
        default:
            return false
        }
    }
}
