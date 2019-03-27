//
//  CryptoFeeService.swift
//  Blockchain
//
//  Created by Jack on 27/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import BitcoinKit
import EthereumKit
import StellarKit
import RxSwift

public protocol FeeServiceAPI {
    /// This pulls from a Blockchain.info endpoint that serves up
    /// current BTC transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var bitcoin: Single<BitcoinTransactionFee> { get }

    /// This pulls from a Blockchain.info endpoint that serves up
    /// current ETH transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var ethereum: Single<EthereumTransactionFee> { get }

    /// This pulls from a Blockchain.info endpoint that serves up
    /// current XLM transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var stellar: Single<StellarTransactionFee> { get }
}

public final class FeeService: FeeServiceAPI {
    static let shared = FeeService()

    // MARK: - FeeServiceAPI

    public var bitcoin: Single<BitcoinTransactionFee> {
        return bitcoinFeeService.fees
    }

    public var ethereum: Single<EthereumTransactionFee> {
        return ethereumFeeService.fees
    }

    public var stellar: Single<StellarTransactionFee> {
        return stellarFeeService.fees
    }

    // MARK: - Private properties

    private let bitcoinFeeService: CryptoFeeService<BitcoinTransactionFee>
    private let ethereumFeeService: CryptoFeeService<EthereumTransactionFee>
    private let stellarFeeService: CryptoFeeService<StellarTransactionFee>

    init(bitcoinFeeService: CryptoFeeService<BitcoinTransactionFee> = CryptoFeeService<BitcoinTransactionFee>.shared,
         ethereumFeeService: CryptoFeeService<EthereumTransactionFee> = CryptoFeeService<EthereumTransactionFee>.shared,
         stellarFeeService: CryptoFeeService<StellarTransactionFee> = CryptoFeeService<StellarTransactionFee>.shared) {
        self.bitcoinFeeService = bitcoinFeeService
        self.ethereumFeeService = ethereumFeeService
        self.stellarFeeService = stellarFeeService
    }
}

public final class CryptoFeeService<T: TransactionFee & Decodable>: CryptoFeeServiceAPI {
    public var fees: Single<T> {
        guard let baseURL = URL(string: apiUrl) else {
            return .error(TradeExecutionAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["mempool", "fees", T.cryptoType.pathComponent],
            queryParameters: nil
        ) else {
            return .error(TradeExecutionAPIError.generic)
        }
        return NetworkRequest.GET(url: endpoint, type: T.self)
            .do(onError: { error in
                // TODO: this should be logged remotely
                Logger.shared.error(error)
            })
            .catchErrorJustReturn(T.default)
    }
    
    private let apiUrl: String
    
    init(apiUrl: String = BlockchainAPI.shared.apiUrl) {
        self.apiUrl = apiUrl
    }
}

extension CryptoFeeService where T == BitcoinTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}

extension CryptoFeeService where T == StellarTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}

extension CryptoFeeService where T == EthereumTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}
