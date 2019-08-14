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
    /// current BTC transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var bitcoinCash: Single<BitcoinCashTransactionFee> { get }

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
    
    public var bitcoinCash: Single<BitcoinCashTransactionFee> {
        return bitcoinCashFeeService.fees
    }

    public var ethereum: Single<EthereumTransactionFee> {
        return ethereumFeeService.fees
    }

    public var stellar: Single<StellarTransactionFee> {
        return stellarFeeService.fees
    }

    // MARK: - Private properties

    private let bitcoinFeeService: CryptoFeeService<BitcoinTransactionFee>
    private let bitcoinCashFeeService: CryptoFeeService<BitcoinCashTransactionFee>
    private let ethereumFeeService: CryptoFeeService<EthereumTransactionFee>
    private let stellarFeeService: CryptoFeeService<StellarTransactionFee>

    init(bitcoinFeeService: CryptoFeeService<BitcoinTransactionFee> = CryptoFeeService<BitcoinTransactionFee>.shared,
         bitcoinCashFeeService: CryptoFeeService<BitcoinCashTransactionFee> = CryptoFeeService<BitcoinCashTransactionFee>.shared,
         ethereumFeeService: CryptoFeeService<EthereumTransactionFee> = CryptoFeeService<EthereumTransactionFee>.shared,
         stellarFeeService: CryptoFeeService<StellarTransactionFee> = CryptoFeeService<StellarTransactionFee>.shared) {
        self.bitcoinFeeService = bitcoinFeeService
        self.bitcoinCashFeeService = bitcoinCashFeeService
        self.ethereumFeeService = ethereumFeeService
        self.stellarFeeService = stellarFeeService
    }
}

extension CryptoFeeService where T == BitcoinTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}

extension CryptoFeeService where T == BitcoinCashTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}

class EthereumFeeService: EthereumFeeServiceAPI {
    static let shared: EthereumFeeService = EthereumFeeService()
    
    // MARK: Public Properties
    
    var fees: Single<EthereumTransactionFee> {
        return cryptoFeeService.fees
    }
    
    private let cryptoFeeService: CryptoFeeService<EthereumTransactionFee>
    
    init(cryptoFeeService: CryptoFeeService<EthereumTransactionFee> = CryptoFeeService<EthereumTransactionFee>.shared) {
        self.cryptoFeeService = cryptoFeeService
    }
}

extension CryptoFeeService where T == EthereumTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}
