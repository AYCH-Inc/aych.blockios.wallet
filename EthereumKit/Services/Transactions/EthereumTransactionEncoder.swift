//
//  EthereumTransactionEncoder.swift
//  EthereumKit
//
//  Created by Jack on 03/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import web3swift
import BigInt
import PlatformKit

public enum EthereumTransactionEncoderError: Error {
    case encodingError
}

public protocol EthereumTransactionEncoderAPI {
    func encode(signed: EthereumTransactionCandidateSigned) -> NewResult<EthereumTransactionFinalised, EthereumTransactionEncoderError>
}

public class EthereumTransactionEncoder: EthereumTransactionEncoderAPI {
    public static let shared = EthereumTransactionEncoder()
    
    public func encode(signed: EthereumTransactionCandidateSigned) -> NewResult<EthereumTransactionFinalised, EthereumTransactionEncoderError> {
        let transaction = signed.transaction
        
        guard let encodedData = transaction.encode() else {
            return .failure(.encodingError)
        }
        
        let rawTxHexString = encodedData.hex.withHex.lowercased()
        
        return .success(
            EthereumTransactionFinalised(
                transaction: transaction,
                rawTx: rawTxHexString
            )
        )
    }
}
