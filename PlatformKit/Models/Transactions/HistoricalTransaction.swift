//
//  HistoricalTransaction.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum Direction {
    case credit
    case debit
}

public protocol HistoricalTransaction: Tokenized {
    associatedtype Address: AssetAddress

    var identifier: String { get }
    var token: String { get }
    var fromAddress: Address { get }
    var toAddress: Address { get }
    var direction: Direction { get }
    var amount: String { get }
    var transactionHash: String { get }
    var createdAt: Date { get }
    var fee: Int? { get }
    var memo: String? { get }
}
