//
//  MockEthereumWalletTestData.swift
//  EthereumKitTests
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt
@testable import EthereumKit

struct MockEthereumWalletTestData {
    static let walletId = "22d57944-bb00-49e5-bc96-e2c31e0a0ff1"
    static let email = "test@blockchain.com"
    
    static let mnemonic = "exercise loop fly noodle various century tooth remember relief castle entire high"
    static let password = "M6rv3L9JavGy3Si%PD5EHTKPz$E9N5"
    static let account = "0xE408d13921DbcD1CBcb69840e4DA465Ba07B7e5e".lowercased()
    
    static let privateKeyHex = "de6e182c9456edeb1148387dadc8f981905377279feb9547d095152ef0f569d9"
    static let privateKeyBase64 = "3m4YLJRW7esRSDh9rcj5gZBTdyef65VH0JUVLvD1adk="
    static let privateKeyData = Data.fromHex(MockEthereumWalletTestData.privateKeyHex)!
    
    static let privateKey = EthereumPrivateKey(
        mnemonic: MockEthereumWalletTestData.mnemonic,
        password: MockEthereumWalletTestData.password
    )
    static let keyPair = EthereumKeyPair(
        accountID: MockEthereumWalletTestData.account,
        privateKey: MockEthereumWalletTestData.privateKey
    )
}

class EthereumTransactionCandidateBuilder {
    var fromAddress: EthereumAssetAddress? = EthereumAssetAddress(
        publicKey: MockEthereumWalletTestData.account
    )
    var toAddress: EthereumAssetAddress? = EthereumAssetAddress(
        publicKey: MockEthereumWalletTestData.account // TODO
    )
    var amount: Decimal? = Decimal(1.0)
    var createdAt: Date? = Date()
    var memo: String?
    
    func with(fromAddress: String) -> Self {
        self.fromAddress = EthereumAssetAddress(publicKey: fromAddress)
        return self
    }
    
    func with(toAddress: String) -> Self {
        self.toAddress = EthereumAssetAddress(publicKey: toAddress)
        return self
    }
    
    func with(amount: Decimal) -> Self {
        self.amount = amount
        return self
    }
    
    func with(memo: String) -> Self {
        self.memo = memo
        return self
    }
    
    func build() -> EthereumTransactionCandidate? {
        guard
            let fromAddress = fromAddress,
            let toAddress = toAddress,
            let amount = amount
        else {
            return nil
        }
        let amountString = NSDecimalNumber(decimal: amount).stringValue
        return EthereumTransactionCandidate(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: amountString,
            createdAt: Date(),
            memo: memo
        )
    }
}

class EthereumTransactionCandidateCostedBuilder {
    var candidate: EthereumTransactionCandidate {
        didSet {
            candidateUpdated()
        }
    }
    
    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    var web3swiftTransaction: web3swift.EthereumTransaction?
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        return self
    }
    
    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }
    
    func build() -> EthereumTransactionCandidateCosted? {
        guard let web3swiftTransaction = web3swiftTransaction else {
            return nil
        }
        return try? EthereumTransactionCandidateCosted(
            transaction: web3swiftTransaction
        )
    }
    
    private func candidateUpdated() {
        web3swiftTransaction = web3swift.EthereumTransaction(
            candidate: candidate
        )
    }
}

class EthereumTransactionCandidateSignedBuilder {
    var candidate: EthereumTransactionCandidate {
        didSet {
            candidateUpdated()
        }
    }
    
    var costed: EthereumTransactionCandidateCosted? {
        didSet {
            web3swiftTransaction = costed?.transaction
        }
    }
    
    var web3swiftTransaction: web3swift.EthereumTransaction?
    
    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        return self
    }
    
    func with(costed: EthereumTransactionCandidateCosted) -> Self {
        self.costed = costed
        return self
    }
    
    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }
    
    func build() -> EthereumTransactionCandidateSigned? {
        guard var transaction = web3swiftTransaction else {
            return nil
        }
        
        let privateKeyData = MockEthereumWalletTestData.privateKeyData
        
        // swiftlint:disable force_try
        try! Web3Signer.EIP155Signer.sign(transaction: &transaction, privateKey: privateKeyData, useExtraEntropy: false)
        // swiftlint:enable force_try
        
        return try? EthereumTransactionCandidateSigned(
            transaction: transaction
        )
    }
    
    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate)
            .build()
        self.costed = costed
    }
}

class EthereumTransactionFinalisedBuilder {
    var candidate: EthereumTransactionCandidate {
        didSet {
            candidateUpdated()
        }
    }
    
    var signed: EthereumTransactionCandidateSigned? {
        didSet {
            web3swiftTransaction = signed?.transaction
        }
    }
    
    var web3swiftTransaction: web3swift.EthereumTransaction?
    
    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        return self
    }
    
    func with(signed: EthereumTransactionCandidateSigned) -> Self {
        self.signed = signed
        return self
    }
    
    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }
    
    func build() -> EthereumTransactionFinalised? {
        guard let web3swiftTransaction = web3swiftTransaction else {
            return nil
        }
        guard let encodedData = web3swiftTransaction.encode() else {
            return nil
        }
        let rawTxHexString = encodedData.hex.withHex.lowercased()
        return EthereumTransactionFinalised(
            transaction: web3swiftTransaction,
            rawTx: rawTxHexString
        )
    }
    
    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate)
            .build()!
        let signed = EthereumTransactionCandidateSignedBuilder()
            .with(costed: costed)
            .build()
        self.signed = signed
    }
}

class EthereumTransactionPublishedBuilder {
    var candidate: EthereumTransactionCandidate {
        didSet {
            candidateUpdated()
        }
    }
    
    var finalised: EthereumTransactionFinalised? =
        EthereumTransactionFinalisedBuilder().build()
    
    var transactionHash: String?
    
    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        return self
    }
    
    func with(finalised: EthereumTransactionFinalised) -> Self {
        self.finalised = finalised
        return self
    }
    
    func with(transactionHash: String) -> Self {
        self.transactionHash = transactionHash
        return self
    }
    
    func build() -> EthereumTransactionPublished? {
        guard let finalised = finalised else {
            return nil
        }
        guard let transactionHash = transactionHash else {
            return EthereumTransactionPublished(
                finalisedTransaction: finalised,
                transactionHash: finalised.transactionHash
            )
        }
        return EthereumTransactionPublished(
            finalisedTransaction: finalised,
            transactionHash: transactionHash
        )
    }
    
    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate)
            .build()!
        let signed = EthereumTransactionCandidateSignedBuilder()
            .with(costed: costed)
            .build()!
        let finalised = EthereumTransactionFinalisedBuilder()
            .with(signed: signed)
            .build()!
        self.finalised = finalised
    }
}

extension web3swift.EthereumTransaction {
    init(candidate: EthereumTransactionCandidate,
             nonce: BigUInt = 9,
          gasPrice: BigUInt = 5_000_000_000,
          gasLimit: BigUInt = 21_000) {
        let to: web3swift.Address = web3swift.Address(candidate.toAddress.publicKey)
        self.init(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: candidate.amount,
            data: Data()
        )
        self.UNSAFE_setChainID(NetworkId.mainnet)
    }
}
