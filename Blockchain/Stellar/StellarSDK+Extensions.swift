//
//  StellarSDK+Extensions.swift
//  Blockchain
//
//  Created by Jack on 03/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import stellarsdk

enum StellarLedgerServiceError: Error {
    case unknown
    case sdkError(Error)
}

protocol LedgerResponseProtocol: Decodable {
    var id: String { get }
    var pagingToken: String { get }
    var sequenceNumber: Int64 { get }
    var successfulTransactionCount: Int? { get }
    var operationCount: Int { get }
    var closedAt: Date { get }
    var totalCoins: String { get }
    var baseFeeInStroops: Int? { get }
    var baseReserveInStroops: Int? { get }
}

extension LedgerResponse: LedgerResponseProtocol {}

protocol PageResponseProtocol: Decodable {
    var allRecords: [LedgerResponseProtocol] { get }
}

extension stellarsdk.PageResponse: PageResponseProtocol where Element: LedgerResponseProtocol {
    var allRecords: [LedgerResponseProtocol] {
        return records as [LedgerResponseProtocol]
    }
}

protocol LedgersServiceAPI {
    func ledgers(
        cursor: String?,
        order: stellarsdk.Order?,
        limit: Int?,
        response: @escaping (Result<PageResponseProtocol, StellarLedgerServiceError>) -> Void
    )
}

protocol StellarSDKLedgersServiceAPI: LedgersServiceAPI {
    func getLedgers(
        cursor: String?,
        order: stellarsdk.Order?,
        limit: Int?,
        response: @escaping stellarsdk.PageResponse<stellarsdk.LedgerResponse>.ResponseClosure
    )
}

extension StellarSDKLedgersServiceAPI {
    func ledgers(
        cursor: String?,
        order: stellarsdk.Order?,
        limit: Int?,
        response: @escaping (Result<PageResponseProtocol, StellarLedgerServiceError>) -> Void)
    {
        getLedgers(cursor: cursor, order: order, limit: limit) { result in
            switch result {
            case .success(let value as PageResponseProtocol):
                response(.success(value))
            case .failure(let error):
                response(.failure(StellarLedgerServiceError.sdkError(error)))
            }
        }
    }
}

extension LedgersService: StellarSDKLedgersServiceAPI {}
