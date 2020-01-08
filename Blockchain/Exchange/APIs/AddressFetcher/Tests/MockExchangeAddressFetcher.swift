//
//  MockExchangeAddressFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Fake address provider by type
class FakeAddress {
    static func address(for type: AssetType) -> String {
        switch type {
        case .ethereum:
            return "0x17836d05892AF892d3CC68C70563B10CFDed19DD"
        case .bitcoin:
            return "3PRRj3H8WPgZLBaYQNrT5Bdw2Z7n12EXKs"
        case .bitcoinCash:
            return "qqaheqhs20u5pvva8d9avn9pr4zyvnfn6gmvuhw45y"
        case .pax:
            return "0x4058a004DD718bABAb47e14dd0d744742E5B9903"
        case .stellar:
            return "GAJBG6YTIVCJ62PYTFDMKIF3RFDRVWEOTX62OKWKNPN7NHBAWLEWKEFI"
        }
    }
}

final class MockExchangeAddressFetcher: ExchangeAddressFetching {
    
    // MARK: - Properties
    
    private let expectedResult: Result<ExchangeAddressFetcher.AddressResponseBody.State, ExchangeAddressFetcher.FetchingError>
    
    // MARK: - Setup
    
    init(expectedResult: Result<ExchangeAddressFetcher.AddressResponseBody.State, ExchangeAddressFetcher.FetchingError>) {
        self.expectedResult = expectedResult
    }
    
    // MARK: - ExchangeAddressFetching
    
    func fetchAddress(for asset: AssetType) -> Single<String> {
        let expectedState: ExchangeAddressFetcher.AddressResponseBody.State
        switch expectedResult {
        case .success(let state):
            expectedState = state
        case .failure(let error):
            return .error(error)
        }
        let data = Data(
            """
                {
                "address": "\(FakeAddress.address(for: asset))",
                "currency": "\(asset.symbol)",
                "state": "\(expectedState.rawValue)"
                }
                """.utf8
        )
        do {
            let result = try JSONDecoder().decode(ExchangeAddressFetcher.AddressResponseBody.self, from: data)
            return .just(result.address)
        } catch {
            return .error(error)
        }
    }
}
