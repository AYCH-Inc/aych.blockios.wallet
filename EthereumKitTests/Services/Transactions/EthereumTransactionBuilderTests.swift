//
//  EthereumTransactionBuilderTests.swift
//  EthereumKitTests
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import web3swift
import BigInt
import PlatformKit
@testable import EthereumKit

class EthereumTransactionBuilderTests: XCTestCase {

    var subject: EthereumTransactionBuilder!
    
    override func setUp() {
        super.setUp()
        
        subject = EthereumTransactionBuilder()
    }
    
    override func tearDown() {
        
        subject = nil
        
        super.tearDown()
    }
    
    func test_build_transaction() {
        let fromAddress: EthereumKit.EthereumTransactionCandidate.Address =
            EthereumKit.EthereumTransactionCandidate.Address(publicKey: MockEthereumWalletTestData.account)
        let toAddress: EthereumKit.EthereumTransactionCandidate.Address = EthereumKit.EthereumTransactionCandidate.Address(
            publicKey: "0x3535353535353535353535353535353535353535"
        )
        let amount: String = "0.01658472"
        let createdAt: Date = Date()
        
        let transaction = EthereumKit.EthereumTransactionCandidate(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: amount,
            createdAt: createdAt
        )!
        
        let nonce = BigUInt(9)
        let gasPrice = BigUInt(23)
        let gasLimit = BigUInt(21_000)
        
        var expectedTransaction = web3swift.EthereumTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: Address(toAddress.publicKey),
            value: transaction.amount,
            data: Data()
        )
        expectedTransaction.UNSAFE_setChainID(NetworkId.mainnet)
        
        let balance = CryptoValue.etherFromMajor(decimal: Decimal(1.0))
        
        let result = subject.build(
            transaction: transaction,
            balance: balance,
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit
        )
        
        guard case .success(let costedTransaction) = result else {
            XCTFail("The transaction should be built successfully")
            return
        }
        
        XCTAssertEqual(costedTransaction.transaction.gasLimit, expectedTransaction.gasLimit)
        XCTAssertEqual(costedTransaction.transaction.gasPrice, expectedTransaction.gasPrice)
        XCTAssertEqual(costedTransaction.transaction.nonce, expectedTransaction.nonce)
        XCTAssertEqual(costedTransaction.transaction.value, expectedTransaction.value)
        XCTAssertEqual(costedTransaction.transaction.txhash, expectedTransaction.txhash)
        XCTAssertEqual(costedTransaction.transaction.intrinsicChainID!, expectedTransaction.intrinsicChainID!)
        XCTAssertEqual(costedTransaction.transaction.intrinsicChainID!, web3swift.NetworkId.mainnet.rawValue)
    }
    
}
