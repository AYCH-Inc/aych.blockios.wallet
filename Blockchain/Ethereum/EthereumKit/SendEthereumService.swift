//
//  SendEthereumService.swift
//  Blockchain
//
//  Created by Jack on 07/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import BigInt
import PlatformKit
import EthereumKit

extension EthereumWalletService {
    static let shared = EthereumWalletService(
        with: WalletManager.shared.wallet.ethereum,
        ethereumAPIClient: EthereumAPIClient.shared,
        feeService: EthereumFeeService.shared,
        walletAccountRepository: ETHServiceProvider.shared.repository,
        transactionCreationService: EthereumTransactionCreationService.shared
    )
}

extension EthereumTransactionCreationService {
    static let shared = EthereumTransactionCreationService(
        with: WalletManager.shared.wallet.ethereum,
        ethereumAPIClient: EthereumAPIClient.shared,
        feeService: EthereumFeeService.shared
    )
}

// TODO:
// * Remove this once we implement native PAX send, this is for testing only

#if DEBUG
@objc class SendEthereumService: NSObject {
    
    static let shared = SendEthereumService()
    
    @objc class func sharedInstance() -> SendEthereumService {
        return SendEthereumService.shared
    }
    
    private var transactionBuilder: EthereumTransactionCandidateBuilder
    
    private let wallet: Wallet
    private let walletService: EthereumWalletServiceAPI
    private let ethereumWalletAccountRepository: EthereumWalletAccountRepository
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         platformService: EthereumWalletServiceAPI = EthereumWalletService.shared,
         ethereumWalletAccountRepository: EthereumWalletAccountRepository = ETHServiceProvider.shared.repository) {
        self.wallet = wallet
        self.walletService = platformService
        self.ethereumWalletAccountRepository = ethereumWalletAccountRepository
        self.transactionBuilder = EthereumTransactionCandidateBuilder()
    }
    
    @objc func changePayment(to address: String) {
        transactionBuilder.with(toAddress: address)
    }
    
    @objc func set(amount: NSDecimalNumber) {
        transactionBuilder.with(amount: amount.decimalValue)
    }
    
    @objc func send() {
        wallet.ethereum.address.subscribe(onSuccess: { address in
            print(address)
            self.transactionBuilder.with(fromAddress: address)
            if let transaction = self.transactionBuilder.build() {
                self.walletService.send(transaction: transaction)
                    .subscribe(onSuccess: { ethereumTransactionPublished in
                        print(ethereumTransactionPublished)
                        self.wallet.delegate?.didSendEther?()
                    }, onError: { error in
                        print(error)
                        self.wallet.delegate?.didErrorDuringEtherSend?(error.localizedDescription)
                    })
            }
        }, onError: { error in
            print(error)
            print(error)
        })
    }
}


class EthereumTransactionCandidateBuilder {
    
    var fromAddress: EthereumAssetAddress?
    var toAddress: EthereumAssetAddress?
    var amountDecimal: Decimal?
    var createdAt: Date?
    
    func with(fromAddress: String) -> Self {
        self.fromAddress = EthereumAssetAddress(publicKey: fromAddress)
        return self
    }
    
    func with(toAddress: String) -> Self {
        self.toAddress = EthereumAssetAddress(publicKey: toAddress)
        return self
    }
    
    func with(amount: Decimal) -> Self {
        self.amountDecimal = amount
        return self
    }
    
    func build() -> EthereumTransactionCandidate? {
        guard
            let fromAddress = fromAddress,
            let toAddress = toAddress,
            let amountDecimal = amountDecimal
        else {
            return nil
        }
        let amountString = NSDecimalNumber(decimal: amountDecimal).stringValue
        guard let amount = BigUInt(amountString, decimals: CryptoCurrency.ethereum.maxDecimalPlaces) else {
            return nil
        }
        let convertedAmountString = amount.string(unitDecimals: CryptoCurrency.ethereum.maxDecimalPlaces)
        return EthereumTransactionCandidate(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: convertedAmountString,
            createdAt: Date(),
            memo: nil
        )
    }
}
#endif
