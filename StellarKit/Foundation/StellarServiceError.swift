//
//  StellarServiceError.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

public enum StellarServiceError: Error, Equatable {
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

public extension StellarServiceError {
    public static func ==(lhs: StellarServiceError, rhs: StellarServiceError) -> Bool {
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

extension HorizonRequestError {
    func toStellarServiceError() -> StellarServiceError {
        switch self {
        case .notFound:
            return .noDefaultAccount
        case .rateLimitExceeded:
            return .rateLimitExceeded
        case .internalServerError:
            return .internalError
        case .parsingResponseFailed:
            return .parsingError
        case .forbidden:
            return .forbidden
        case .badRequest(message: let message, horizonErrorResponse: let response):
            var value = message
            if let response = response {
                value += (" " + response.extras.resultCodes.transaction)
                value += (" " + response.extras.resultCodes.operations.joined(separator: " "))
            }
            return .badRequest(message: value)
        default:
            return .unknown
        }
    }
}
