//
//  ExchangeInteractorStatus.swift
//  Blockchain
//
//  Created by AlexM on 3/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ExchangeInteractorStatus: Equatable {
    case inflight
    case error(ExchangeError)
    case valid
    case unknown
}

extension ExchangeInteractorStatus {
    static func ==(lhs: ExchangeInteractorStatus, rhs: ExchangeInteractorStatus) -> Bool {
        switch (lhs, rhs) {
        case (.inflight, .inflight):
            return true
        case (.error(let left), .error(let right)):
            return left == right
        case (.valid, .valid):
            return true
        default:
            return false
        }
    }
}
