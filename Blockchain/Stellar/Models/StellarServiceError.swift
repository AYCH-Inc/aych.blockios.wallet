//
//  StellarServiceError.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: Should be deprecated in favor of `StellarServiceError` in `StellarKit`
enum StellarServiceError: Error, Equatable {
    case insufficientFundsForNewAccount
    case noDefaultAccount
    case noXLMAccount
    case rateLimitExceeded
    case internalError
    case parsingError
    case unauthorized
    case forbidden
    case amountTooLow
    case badRequest(message: String)
    case unknown
}

extension StellarServiceError {
    static func ==(lhs: StellarServiceError, rhs: StellarServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.insufficientFundsForNewAccount, .insufficientFundsForNewAccount),
             (.noDefaultAccount, .noDefaultAccount),
             (.noXLMAccount, .noXLMAccount),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.internalError, .internalError),
             (.parsingError, .parsingError),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.amountTooLow, .amountTooLow),
             (.unknown, .unknown):
            return true
        case (.badRequest(message: let left), .badRequest(message: let right)):
            return left == right
        default:
            return false
        }
    }
}
