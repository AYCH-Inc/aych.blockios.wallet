//
//  SimpleListPageResponse.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct SListPageResponse<ListItem: Identifiable> {
    let results: [ListItem]
    let hasNextPage: Bool
}

protocol SimpleListPageResponse {
    associatedtype ListItem: Identifiable
    var results: [ListItem] { get }
    var hasNextPage: Bool { get }
}

struct StellarListPageResponse: SimpleListPageResponse {
    var results: [StellarTransaction]

    var hasNextPage: Bool

    typealias ListItem = StellarTransaction
}

struct StellarTransaction: Identifiable {
    let identifier: String
}
