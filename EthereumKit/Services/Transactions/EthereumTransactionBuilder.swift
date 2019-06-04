//
//  EthereumTransactionBuilder.swift
//  EthereumKit
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import web3swift
import BigInt
import PlatformKit

public enum EthereumTransactionBuilderError: Error {
    case insufficientFunds
    case invalidAmount
}

public protocol EthereumTransactionBuilderAPI {
    func build(
        transaction: EthereumTransactionCandidate,
        balance: CryptoValue,
        nonce: BigUInt,
        gasPrice: BigUInt,
        gasLimit: BigUInt
    ) -> NewResult<EthereumTransactionCandidateCosted, EthereumTransactionBuilderError>
}

public class EthereumTransactionBuilder: EthereumTransactionBuilderAPI {
    public static let shared = EthereumTransactionBuilder()
    
    public func build(
        transaction: EthereumTransactionCandidate,
        balance: CryptoValue,
        nonce: BigUInt,
        gasPrice: BigUInt,
        gasLimit: BigUInt
        ) -> NewResult<EthereumTransactionCandidateCosted, EthereumTransactionBuilderError> {
        
        print("transaction.amount: \(transaction.amount)")
        
        let value = transaction.amount
        
        let balanceUnisigned = BigUInt(balance.amount)
        
        let fee = gasPrice * gasLimit
        
        print("gasPrice: \(gasPrice)")
        print("gasLimit: \(gasLimit)")
        print("     fee: \(fee)")
        print("   value: \(value)")
        print("\n")
        print("             fee.string(unitDecimals: 18): \(fee.string(unitDecimals: CryptoCurrency.ethereum.maxDecimalPlaces))")
        print("balanceUnisigned.string(unitDecimals: 18): \(balanceUnisigned.string(unitDecimals: CryptoCurrency.ethereum.maxDecimalPlaces))")
        print("           value.string(unitDecimals: 18): \(value.string(unitDecimals: CryptoCurrency.ethereum.maxDecimalPlaces))")
        print("\n")
        
        guard fee < balanceUnisigned else {
            return .failure(.insufficientFunds)
        }
        
        let availableBalance = balanceUnisigned - fee
        
        print("availableBalance: \(availableBalance)")
        
        guard value < availableBalance else {
            return .failure(.insufficientFunds)
        }
        
        // TODO:
        // * Make sure this is an EIP-55 address
        let to: web3swift.Address = web3swift.Address(transaction.toAddress.publicKey)
        
        var tx: web3swift.EthereumTransaction = web3swift.EthereumTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: value,
            data: Data()
        )
        tx.UNSAFE_setChainID(NetworkId.mainnet)
        
        print("tx.gasPrice: \(tx.gasPrice)")
        print("tx.gasLimit: \(tx.gasLimit)")
        print("   tx.value: \(tx.value)")
        print("   tx.value.string(unitDecimals: 18): \(tx.value.string(unitDecimals: 18))")
        
        // swiftlint:disable force_try
        return .success(try! EthereumTransactionCandidateCosted(transaction: tx))
        // swiftlint:enable force_try
    }
}
