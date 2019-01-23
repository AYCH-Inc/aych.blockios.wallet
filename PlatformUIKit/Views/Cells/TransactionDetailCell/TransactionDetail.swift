//
//  TransactionDetail.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct TransactionDetail: Equatable {
    let description: String
    let value: String
    let backgroundColor: UIColor
    let statusVisibility: Visibility
    let statusTintColor: UIColor
    let bold: Bool
    
    init(
        description: String,
        value: String,
        backgroundColor: UIColor = .white,
        statusVisibility: Visibility = .hidden,
        bold: Bool = false,
        statusTintColor: UIColor = .green
        ) {
        self.description = description
        self.value = value
        self.backgroundColor = backgroundColor
        self.statusVisibility = statusVisibility
        self.bold = bold
        self.statusTintColor = statusTintColor
    }
}

public extension TransactionDetail {
    public static func ==(lhs: TransactionDetail, rhs: TransactionDetail) -> Bool {
        return lhs.description == rhs.description &&
        lhs.value == rhs.value &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.statusVisibility == rhs.statusVisibility &&
        lhs.statusTintColor == rhs.statusTintColor &&
        lhs.bold == rhs.bold
    }
}

public extension TransactionDetail {
    
    public static let demo1: TransactionDetail = TransactionDetail(
        description: "This is a demo description",
        value: "This is a demo value"
    )
    
    public static let demo2: TransactionDetail = TransactionDetail(
        description: "This is a demo description",
        value: "$1234",
        backgroundColor: .darkBlue,
        statusVisibility: .visible,
        bold: true,
        statusTintColor: .green
    )
    
}
