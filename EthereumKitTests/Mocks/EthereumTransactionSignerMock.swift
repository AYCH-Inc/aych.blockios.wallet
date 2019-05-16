//
//  EthereumTransactionSignerMock.swift
//  EthereumKitTests
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
@testable import EthereumKit

class EthereumTransactionSignerMock: EthereumTransactionSignerAPI {
    var lastTransactionForSignature: EthereumTransactionCandidateCosted?
    var lastKeyPair: EthereumKeyPair?
    var signTransactionResult:  NewResult<EthereumTransactionCandidateSigned, EthereumTransactionSignerError> = NewResult.failure(.incorrectChainId)
    func sign(transaction: EthereumTransactionCandidateCosted, keyPair: EthereumKeyPair) -> NewResult<EthereumTransactionCandidateSigned, EthereumTransactionSignerError> {
        lastTransactionForSignature = transaction
        lastKeyPair = keyPair
        return signTransactionResult
    }
}
